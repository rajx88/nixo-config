{
  pkgs,
  lib,
  config,
  ...
}: let
  swaylockPkg = pkgs.swaylock-effects;
  swaylock = "${swaylockPkg}/bin/swaylock";
  pgrep = "${pkgs.procps}/bin/pgrep";
  pactl = "${pkgs.pulseaudio}/bin/pactl";

  isLocked = "${pgrep} -f ${swaylock}";
  lockTime = 60; # TODO: change back to 10 * 60 after testing

  afterLockTimeout = {
    timeout,
    command,
    resumeCommand ? null,
  }: [
    {
      timeout = lockTime + timeout;
      inherit command resumeCommand;
    }
    {
      command = "${isLocked} && ${command}";
      inherit resumeCommand timeout;
    }
  ];

  commonArgs = "--clock --indicator --timestr '%k:%M' --datestr '%a %e.%m.%Y' --daemonize";

  lockScriptBin = pkgs.writeShellScriptBin "swaylock-lock" ''
    if [ -n "$LOCKSCREEN_WP" ] && [ -f "$LOCKSCREEN_WP" ]; then
      exec ${swaylock} -i "$LOCKSCREEN_WP" ${commonArgs}
    else
      exec ${swaylock} --screenshots --effect-scale 0.5 --effect-blur 10x3 ${commonArgs}
    fi
  '';

  # Skip when hypridle is handling idle/lock (e.g. hyprland uses hyprlock/hypridle)
  enabled = !config.services.hypridle.enable;
in {
  programs.swaylock = lib.mkIf enabled {
    enable = true;
    package = swaylockPkg;
  };

  home.packages = lib.mkIf enabled [ lockScriptBin ];

  services.swayidle = lib.mkIf enabled {
    enable = true;
    systemdTargets = [ "graphical-session.target" ];
    timeouts =
      [
        {
          timeout = lockTime;
          command = "${lockScriptBin}/bin/swaylock-lock";
        }
      ]
      ++
      # Mute mic
      (afterLockTimeout {
        timeout = 10;
        command = "${pactl} set-source-mute @DEFAULT_SOURCE@ yes";
        resumeCommand = "${pactl} set-source-mute @DEFAULT_SOURCE@ no";
      });
  };
}
