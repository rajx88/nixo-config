{
  pkgs,
  lib,
  config,
  ...
}:
let
  # NVIDIA NeMo Switchyard: local model router in front of the homelab new-api
  # gateway. Runs on the laptop (not the homelab) as a localhost-only user
  # service. Agents pick a route per task:
  #   sy/claude-auto  — Haiku by default, Sonnet when the agent struggles
  #   sy/claude-heavy — Sonnet by default, Opus when the agent struggles
  # Claude Code is intentionally NOT routed through this. new-api serves both
  # Copilot subscriptions; switchyard only picks a model per task.
  #
  # The router ships no UI and clients only see the route alias. The selected
  # model is reported per request in the `x-model-router-selected-model`
  # response header, in the response body's `model` field, and in
  # ~/.local/state/switchyard/routing.jsonl.
  port = 4123;
  gatewayDir = "${config.home.homeDirectory}/.local/share/newapi";
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
    # The built-in vocabulary only knows read/write/edit/bash/grep/glob/list and
    # a few patch tools. Agent harnesses hand us other names, and an unknown
    # tool counts as churn: every turn scored "spinning" ~0.75, confidence
    # stayed under 0.5, and all 16 decisions in one session fall-opened to the
    # efficient tier. `new` suppresses that false churn signal without favoring
    # a tier; fetches and code-graph reads are investigation.
    # Built-in names must stay out (reclassifying them is rejected).
    tool_semantics = {
      observe = [
        "codegraph_codegraph_explore"
        "codegraph_explore"
        "webfetch"
        "websearch"
      ];
      new = [
        "execute"
        "skill"
        "question"
      ];
    };
  };

  # base_url is filled in at service start from ~/.local/share/newapi/base-url
  # so the gateway hostname stays out of git.
  routes = (pkgs.formats.toml { }).generate "switchyard-routes.toml" {
    schema_version = 1;
    fallback_client = "newapi";
    llm_clients.newapi = {
      format = "anthropic_messages";
      base_url = "@NEWAPI_BASE_URL@";
      api_key_env = "NEWAPI_API_KEY";
      max_retries = 2;
    };
    targets = {
      haiku = {
        id = model "claude-haiku-5.5";
        llm_client = "newapi";
      };
      sonnet = {
        id = model "claude-sonnet-5.5";
        llm_client = "newapi";
      };
      opus = {
        id = model "claude-opus-5.5";
        llm_client = "newapi";
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
        sed 's|@NEWAPI_BASE_URL@|https://example.invalid|' ${routes} > check.toml
        NEWAPI_API_KEY=dummy ${lib.getExe pkgs.switchyard} --config check.toml --dry-run
        cp ${routes} $out
      '';

  start = pkgs.writeShellScript "switchyard-start" ''
    set -euo pipefail
    dir=${gatewayDir}
    key=$dir/switchyard-key
    NEWAPI_API_KEY=$(cat "$key")
    export NEWAPI_API_KEY
    base=$(cat "$dir/base-url")
    cfg="$XDG_RUNTIME_DIR/switchyard/routes.toml"
    mkdir -p "$(dirname "$cfg")" ${stateDir}
    ${pkgs.gnused}/bin/sed "s|@NEWAPI_BASE_URL@|$base|" ${checkedRoutes} > "$cfg"
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
        gatewayDir
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
  # Switchyard holds the new-api key itself, so the client key is a dummy.
  # Contributed to the Nix-owned overrides.json (see features/dev/opencode.nix)
  # rather than programs.opencode.settings, so opencode.json stays unmanaged
  # and writable by tooling.
  # Native v2 provider shape: `providers` (not `provider`), `package` with the
  # `aisdk:` prefix, request settings under `settings`, and model capabilities
  # under `capabilities` (v2 has no `reasoning`/`attachment` model fields).
  opencodeOverrides.providers.switchyard = {
    package = "aisdk:@ai-sdk/anthropic";
    name = "Switchyard";
    settings = {
      baseURL = "http://127.0.0.1:${toString port}/v1";
      apiKey = "switchyard-local";
    };
    models = lib.mapAttrs (_: name: {
      inherit name;
      capabilities = {
        tools = true;
        input = [
          "text"
          "image"
        ];
        output = [ "text" ];
      };
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
    ".local/share/newapi" # base-url, switchyard-key (not in git)
    ".local/state/switchyard" # routing.jsonl
  ];
}
