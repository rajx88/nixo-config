{
  pkgs,
  lib,
  config,
  ...
}:
let
  # NVIDIA NeMo Switchyard: local model router in front of the homelab LiteLLM
  # gateway. Runs on the laptop (not the homelab) as a localhost-only user
  # service. Agents pick a route per task:
  #   sy/claude-auto  — Haiku by default, Sonnet when the agent struggles
  #   sy/claude-heavy — Sonnet by default, Opus when the agent struggles
  # Claude Code is intentionally NOT routed through this; it keeps its own
  # opus/sonnet/haiku mapping straight to LiteLLM.
  port = 4123;
  litellmDir = "${config.home.homeDirectory}/.local/share/litellm";
  stateDir = "${config.home.homeDirectory}/.local/state/switchyard";

  model = name: "github_copilot/${name}";

  # Verified against the upstream Copilot gateway: Haiku accepted ~700k input
  # tokens, Opus ~700k, Sonnet ~840k (rejected at ~1.26M, max 1M). 400k sits
  # below the lowest verified limit, so it is safe for both routes.
  contextWindow = 400000;
  maxOutput = 32000;

  routeNames = {
    "sy/claude-auto" = "Switchyard auto (Haiku ↔ Sonnet)";
    "sy/claude-heavy" = "Switchyard heavy (Sonnet ↔ Opus)";
  };

  stage = capable: efficient: {
    type = "stage_router";
    capable_target = capable;
    efficient_target = efficient;
    picker = "efficient_first";
    confidence_threshold = 0.5;
    capable_hold_turns = 2;
    tool_calling = true;
    reasoning = true;
    vision = true;
    context_window = contextWindow;
  };

  # base_url is filled in at service start from ~/.local/share/litellm/base-url
  # so the gateway hostname stays out of git.
  routes = (pkgs.formats.toml { }).generate "switchyard-routes.toml" {
    schema_version = 1;
    fallback_client = "litellm";
    llm_clients.litellm = {
      format = "anthropic_messages";
      base_url = "@LITELLM_BASE_URL@";
      api_key_env = "LITELLM_API_KEY";
      max_retries = 2;
    };
    targets = {
      haiku = {
        id = model "claude-haiku-5.5";
        llm_client = "litellm";
      };
      sonnet = {
        id = model "claude-sonnet-5.5";
        llm_client = "litellm";
      };
      opus = {
        id = model "claude-opus-5.5";
        llm_client = "litellm";
      };
    };
    routes = {
      claude_auto = {
        id = "sy/claude-auto";
      }
      // stage "sonnet" "haiku";
      claude_heavy = {
        id = "sy/claude-heavy";
      }
      // stage "opus" "sonnet";
    };
  };

  # Fail the build if upstream rejects the generated config.
  checkedRoutes =
    pkgs.runCommand "switchyard-routes-checked.toml"
      {
        SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
      }
      ''
        sed 's|@LITELLM_BASE_URL@|https://example.invalid|' ${routes} > check.toml
        LITELLM_API_KEY=dummy ${lib.getExe pkgs.switchyard} --config check.toml --dry-run
        cp ${routes} $out
      '';

  start = pkgs.writeShellScript "switchyard-start" ''
    set -euo pipefail
    dir=${litellmDir}
    key=$dir/switchyard-key
    [ -s "$key" ] || key=$dir/master-key
    LITELLM_API_KEY=$(cat "$key")
    export LITELLM_API_KEY
    base=$(cat "$dir/base-url")
    cfg="$XDG_RUNTIME_DIR/switchyard/routes.toml"
    mkdir -p "$(dirname "$cfg")" ${stateDir}
    ${pkgs.gnused}/bin/sed "s|@LITELLM_BASE_URL@|$base|" ${checkedRoutes} > "$cfg"
    exec ${lib.getExe pkgs.switchyard} --config "$cfg" \
      --host 127.0.0.1 --port ${toString port} \
      --routing-log-file ${stateDir}/routing.jsonl
  '';
in
{
  home.packages = [ pkgs.switchyard ];

  systemd.user.services.switchyard = {
    Unit = {
      Description = "NVIDIA NeMo Switchyard model router (localhost)";
      After = [ "network-online.target" ];
      # Wait for the impermanence bind mount holding base-url and the key;
      # a ConditionPathExists here races the mount on first activation.
      RequiresMountsFor = [
        litellmDir
        stateDir
      ];
    };
    Service = {
      ExecStart = "${start}";
      Restart = "on-failure";
      RestartSec = 5;
      Environment = [ "RUST_LOG=switchyard_server=info" ];
    };
    Install.WantedBy = [ "default.target" ];
  };

  # opencode: Anthropic-compatible provider pointing at the local router.
  # Switchyard holds the LiteLLM key itself, so the client key is a dummy.
  programs.opencode.settings.provider.switchyard = {
    npm = "@ai-sdk/anthropic";
    name = "Switchyard";
    options = {
      baseURL = "http://127.0.0.1:${toString port}/v1";
      apiKey = "switchyard-local";
    };
    models = lib.mapAttrs (_: name: {
      inherit name;
      reasoning = true;
      tool_call = true;
      attachment = true;
      limit = {
        context = contextWindow;
        output = maxOutput;
      };
    }) routeNames;
  };

  # omp: anthropic-messages so omp sends a session id (needed for
  # capable_hold_turns), adaptive thinking so Claude accepts it.
  home.file.".omp/agent/models.yml".text = lib.generators.toYAML { } {
    providers.switchyard = {
      baseUrl = "http://127.0.0.1:${toString port}";
      api = "anthropic-messages";
      auth = "none";
      models = lib.mapAttrsToList (id: name: {
        inherit id name;
        reasoning = true;
        input = [
          "text"
          "image"
        ];
        contextWindow = contextWindow;
        maxTokens = maxOutput;
        thinking = {
          mode = "anthropic-adaptive";
          efforts = [
            "low"
            "medium"
            "high"
          ];
        };
      }) routeNames;
    };
  };

  home.persistence."/persist".directories = [
    ".local/share/litellm" # base-url, master-key, switchyard-key (not in git)
    ".local/state/switchyard" # routing.jsonl
  ];
}
