{
  pkgs,
  lib,
  config,
  ...
}: {
  home.packages = [pkgs.claude-code];

  # LLM-backed consolidation + auto-consolidation via Claude Code, routed
  # through a LiteLLM gateway (GitHub Copilot backend). The gateway base URL
  # and master key are read at runtime from
  # ~/.local/share/litellm/{base-url,master-key} — never stored in the nix
  # store or this repository.
  home.file.".config/icm/config.toml".text = ''
    [consolidate.summarizer]
    provider = "claude"
    model = "github_copilot/claude-sonnet-5"

    [memory]
    auto_consolidate_enabled = true
    auto_consolidate_threshold = 100
  '';

  # Daily maintenance: drain the async consolidation queue (LLM via LiteLLM),
  # then decay and prune. Without the master key, consolidation is skipped
  # but decay/prune still run. Only created when icm is enabled.
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
            export PATH="${pkgs.claude-code}/bin:${pkgs.icm}/bin:${pkgs.coreutils}/bin:''${PATH:-}"

            if [ -f "$HOME/.local/share/litellm/master-key" ] && [ -f "$HOME/.local/share/litellm/base-url" ]; then
              export ANTHROPIC_BASE_URL="$(cat "$HOME/.local/share/litellm/base-url")"
              export ANTHROPIC_AUTH_TOKEN="$(cat "$HOME/.local/share/litellm/master-key")"
              export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1
              export DISABLE_NON_ESSENTIAL_MODEL_CALLS=1
              ${pkgs.icm}/bin/icm consolidate-pending --limit 10 || true
            else
              echo "[icm-maintenance] litellm secrets missing under ~/.local/share/litellm/ — skipping consolidation"
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

  home.persistence."/persist".directories = [
    ".local/share/litellm"
  ];
}
