{
  pkgs,
  lib,
  config,
  ...
}: {
  # Importing this module is what turns icm (and its maintenance timer) on.
  #
  # `icm init` detects Pi (via the `pi` binary / ~/.pi/agent), not omp
  # (~/.omp/agent), so the files it normally generates for Pi / Claude Code
  # are managed here instead:
  #   - icm.ts               -> auto-inject recall + auto-extract tool output
  #   - APPEND_SYSTEM.md     -> persistent-memory instructions (cli mode)
  #   - skills/icm-*.md      -> /icm-recall + /icm-remember (skill mode)
  options.programs.icm.summarizer = lib.mkOption {
    type = lib.types.nullOr (lib.types.enum ["claude-litellm" "codex"]);
    default = null;
    description = ''
      Which LLM backend consolidates ICM memories. `null` runs decay/prune
      daily but skips LLM-backed consolidation entirely.

      - "claude-litellm": Claude Code routed through a LiteLLM gateway
        (GitHub Copilot backend). Gateway secrets are read at runtime from
        ~/.local/share/litellm/{base-url,master-key} — never stored in the
        nix store or this repository.
      - "codex": Codex CLI over the OpenCode Go subscription (see
        features/dev/codex.nix), authenticated via
        ~/.local/share/opencode/auth.json.
    '';
  };

  config = let
    summarizer = config.programs.icm.summarizer;

    # Rebuilds codex.nix's --skip-git-repo-check shim locally rather than
    # reaching into that module's private binding: icm shells out to plain
    # `codex exec`, which refuses to run outside a git repo unless this flag
    # is passed, and icm has no way to pass it itself.
    codexForIcm = pkgs.writeShellScriptBin "codex" ''
      if [ "''${1:-}" = "exec" ]; then
        shift
        exec ${pkgs.codex}/bin/codex exec --skip-git-repo-check "$@"
      fi
      exec ${pkgs.codex}/bin/codex "$@"
    '';

    configToml =
      if summarizer == "claude-litellm"
      then ''
        [consolidate.summarizer]
        provider = "claude"
        model = "github_copilot/claude-sonnet-5"

        [memory]
        # icm's own async auto-consolidate enqueue only fires on some write
        # paths (observed: never for our CLI/extract-pending-driven writes,
        # only sporadically otherwise) — most topics that cross the threshold
        # never get enqueued at all, so draining the queue leaves real
        # backlog uncollected. Disabled; `consolidate-all` below is the sole,
        # reliable mechanism since it scans live topic counts unconditionally
        # instead of depending on that queue.
        auto_consolidate_enabled = false
        auto_consolidate_threshold = 100
      ''
      else if summarizer == "codex"
      then ''
        [consolidate.summarizer]
        provider = "codex"
        model = "gpt-5.6-luna"

        [memory]
        auto_consolidate_enabled = false
        auto_consolidate_threshold = 100
      ''
      else null;

    summarizerEnv =
      if summarizer == "claude-litellm"
      then ''
        export PATH="${pkgs.claude-code}/bin:''${PATH:-}"
        if [ -f "$HOME/.local/share/litellm/master-key" ] && [ -f "$HOME/.local/share/litellm/base-url" ]; then
          export ANTHROPIC_BASE_URL="$(cat "$HOME/.local/share/litellm/base-url")"
          export ANTHROPIC_AUTH_TOKEN="$(cat "$HOME/.local/share/litellm/master-key")"
          export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1
          export DISABLE_NON_ESSENTIAL_MODEL_CALLS=1
          ICM_SUMMARIZER_READY=1
        fi
      ''
      else if summarizer == "codex"
      then ''
        export PATH="${codexForIcm}/bin:${pkgs.jq}/bin:''${PATH:-}"
        if [ -f "$HOME/.local/share/opencode/auth.json" ]; then
          export OPENCODE_GO_API_KEY="$(${pkgs.jq}/bin/jq -r '.["opencode-go"].key' "$HOME/.local/share/opencode/auth.json")"
          ICM_SUMMARIZER_READY=1
        fi
      ''
      else "";

    extraPackages =
      if summarizer == "claude-litellm"
      then [pkgs.claude-code]
      else [];

    extraPersistence =
      if summarizer == "claude-litellm"
      then [".local/share/litellm"]
      else [];
  in {
    home.packages = [pkgs.icm] ++ extraPackages;

    home.persistence."/persist".directories = [".local/share/icm"] ++ extraPersistence;

    home.file =
      {
        ".omp/agent/extensions/icm.ts".source = ./omp-icm.ts;
        ".omp/agent/APPEND_SYSTEM.md".source = ./omp-append-system.md;
        ".omp/agent/skills/icm-recall.md".source = ./omp-skills/icm-recall.md;
        ".omp/agent/skills/icm-remember.md".source = ./omp-skills/icm-remember.md;
      }
      // lib.optionalAttrs (configToml != null) {
        ".config/icm/config.toml".text = configToml;
      };

    # Daily maintenance: consolidate every topic over the threshold, then
    # decay and prune. consolidate-all scans topic counts directly (live,
    # unconditional) rather than draining icm's own async auto-consolidate
    # queue — that queue only fires on some write paths and leaves most
    # over-threshold topics with no job ever created, so it's disabled
    # (`auto_consolidate_enabled = false` above) rather than relied on.
    # Consolidation itself is skipped (decay/prune still run) when
    # `programs.icm.summarizer` is null or its secrets aren't available yet.
    systemd.user.services.icm-maintenance = {
      Unit = {
        Description = "ICM memory maintenance (consolidation, decay, prune)";
        After = ["network.target"];
      };
      Service = {
        Type = "oneshot";
        ExecStart = let
          script = pkgs.writeShellScript "icm-maintenance" ''
            export PATH="${pkgs.icm}/bin:${pkgs.coreutils}/bin:''${PATH:-}"

            ICM_SUMMARIZER_READY=0
            ${summarizerEnv}

            if [ "$ICM_SUMMARIZER_READY" = 1 ]; then
              icm consolidate-all --threshold 100 || true
            else
              echo "[icm-maintenance] no summarizer configured — skipping consolidation"
            fi

            icm decay || true
            icm prune || true
          '';
        in "${script}";
      };
    };

    systemd.user.timers.icm-maintenance = {
      Unit.Description = "Daily ICM memory maintenance";
      Timer = {
        OnCalendar = "daily";
        OnBootSec = "5m"; # also run shortly after each boot/login, since this
        # machine is usually off overnight and the daily calendar slot can be
        # missed entirely otherwise
        # Requires `linger` enabled for this user (hosts/_common/users) so the
        # user systemd instance keeps running across logout/idle instead of
        # being torn down between sessions — without that, this daily
        # calendar timer would rarely survive long enough to actually fire.
        Persistent = true; # catch up a missed run if the machine was off/asleep through the window
        RandomizedDelaySec = "15m";
      };
      Install.WantedBy = ["timers.target"];
    };
  };
}
