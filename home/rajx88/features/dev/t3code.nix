{
  pkgs,
  config,
  lib,
  ...
}:
let
  home = config.home.homeDirectory;

  # XDG: persistent user data lives in `share`, not `~/.config`.
  t3Home = "${home}/.local/share/t3";
in
{
  # T3 Code: conversational multi-agent GUI + `t3` CLI/server. Both are
  # repo-local prebuilt packages (pkgs/t3code from the .deb, pkgs/t3code-cli
  # from the release tarball) so we track upstream without waiting on nixpkgs.
  # Provider CLIs (opencode, claude, cursor) come from the Home PATH.
  #
  # They share one T3 home. The server runs as the user service below, so agent
  # work survives closing the UI, logout and reboot. The desktop app must have
  # its "Local environment" switch off (Settings -> Connections) so it attaches
  # to this service instead of spawning a second server that would fight it for
  # the data directory.
  home.packages = [
    pkgs.t3code
    pkgs.t3code-cli
  ];

  # Makes the CLI resolve to the server's data directory without flags.
  # pkgs/t3code defaults the GUI to the same path (session variables do not
  # reach compositor-launched apps).
  home.sessionVariables.T3CODE_HOME = t3Home;

  home.persistence."/persist".directories = [
    ".local/share/t3" # db, settings, auth, attachments, tools, logs
    ".config/t3code-v2" # Electron userData
  ];

  # Mirrors upstream's own `t3 service install` unit (same unit name, restart
  # and OOM semantics) so `systemctl --user status t3code` and `t3 service
  # status` both work. Do NOT run `t3 service install` or `t3 update`: they
  # would overwrite this unit / install a pinned runtime into the data dir.
  systemd.user.services.t3code = {
    Unit = {
      Description = "T3 Code server";
      StartLimitIntervalSec = 300;
      StartLimitBurst = 5;
      After = [ "network.target" ];
    };

    Service = {
      Type = "simple";
      WorkingDirectory = "%h";

      # A user unit gets no login-shell PATH; the server spawns the provider
      # CLIs (opencode, claude, ...) from PATH and needs its own `t3`.
      Environment = [
        "T3CODE_HOME=${t3Home}"
        "T3CODE_DISABLE_AUTO_UPDATE=true"
        "PATH=${
          lib.makeBinPath [ pkgs.t3code-cli ]
        }:${config.home.profileDirectory}/bin:${home}/.local/bin:/run/current-system/sw/bin"
      ];

      # Log to the journal. systemd opens append: targets *before* it runs
      # ExecStartPre, so logging into a not-yet-created directory fails the
      # whole start (209/STDOUT). `journalctl --user -u t3code` has it all.

      ExecStart = "${pkgs.t3code-cli}/bin/t3 serve --host 127.0.0.1 --port 3773";

      KillMode = "mixed";
      OOMPolicy = "continue";
      Restart = "always";
      RestartSec = 5;
    };

    Install.WantedBy = [ "default.target" ];
  };
}
