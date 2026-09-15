{
  pkgs,
  lib,
  config,
  ...
}: let
  # icm shells out to `codex exec` non-interactively, which refuses to run
  # outside a git repo (e.g. from ~) unless --skip-git-repo-check is passed —
  # and icm has no way to pass it. This wrapper adds the flag to exec
  # invocations only; interactive TUI use is passed through untouched.
  codexWrapped = pkgs.writeShellScriptBin "codex" ''
    if [ "''${1:-}" = "exec" ]; then
      shift
      exec ${pkgs.codex}/bin/codex exec --skip-git-repo-check "$@"
    fi
    exec ${pkgs.codex}/bin/codex "$@"
  '';
in {
  home.packages = [
    codexWrapped
    pkgs.jq # used by the OPENCODE_GO_API_KEY bootstrap below
  ];

  # Codex CLI backed by the OpenCode Go subscription.
  # NOTE: ~/.codex/config.toml is intentionally NOT managed by home-manager.
  # Codex persists trust decisions and other state into it at runtime, which
  # fails against a read-only /nix/store symlink. It lives as a plain file in
  # the persisted ~/.codex directory instead.

  # Reuse opencode's persisted Go API key instead of duplicating the secret.
  programs.fish.interactiveShellInit = ''
    if not set -q OPENCODE_GO_API_KEY; and test -f $HOME/.local/share/opencode/auth.json
        set -gx OPENCODE_GO_API_KEY (jq -r '.["opencode-go"].key' $HOME/.local/share/opencode/auth.json)
    end
  '';

  home.persistence."/persist".directories = [
    ".codex" # sessions, history, login state
  ];

  # Daily ICM maintenance: drain the async consolidation queue (LLM via the
  # codex summarizer over opencode-go), then decay and prune. Mirrors the
  # icm-litellm timer on yuji; on akarnae the summarizer is codex, so the
  # env here is OPENCODE_GO_API_KEY instead of the LiteLLM gateway.
  # Only created when icm is actually enabled on this machine.
  systemd.user = lib.mkIf config.programs.icm.enable {
    services.icm-maintenance = {
      Unit = {
        Description = "ICM memory maintenance (consolidation, decay, prune)";
        After = ["network.target"];
      };
      Service = {
        Type = "oneshot";
        ExecStart = let
          script = pkgs.writeShellScript "icm-maintenance" ''
            export PATH="${codexWrapped}/bin:${pkgs.icm}/bin:${pkgs.jq}/bin:${pkgs.coreutils}/bin:''${PATH:-}"

            if [ -f "$HOME/.local/share/opencode/auth.json" ]; then
              export OPENCODE_GO_API_KEY="$(${pkgs.jq}/bin/jq -r '.["opencode-go"].key' "$HOME/.local/share/opencode/auth.json")"
              ${pkgs.icm}/bin/icm consolidate-pending --limit 10 || true
            else
              echo "[icm-maintenance] opencode auth.json missing — skipping consolidation"
            fi

            ${pkgs.icm}/bin/icm decay || true
            ${pkgs.icm}/bin/icm prune || true
          '';
        in "${script}";
      };
    };

    timers.icm-maintenance = {
      Unit = {
        Description = "Daily ICM memory maintenance";
      };
      Timer = {
        OnCalendar = "daily";
        Persistent = true;
        RandomizedDelaySec = "15m";
      };
      Install = {
        WantedBy = ["timers.target"];
      };
    };
  };
}
