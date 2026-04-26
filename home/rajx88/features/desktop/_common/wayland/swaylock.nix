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
  brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl";
  wlopm = "${pkgs.wlopm}/bin/wlopm";
  isDischarging = "grep -q Discharging /sys/class/power_supply/BAT*/status 2>/dev/null";

  isLocked = "${pgrep} -x swaylock";
  lockTime = 10 * 60;

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

  lockscreenWp = config.home.sessionVariables.LOCKSCREEN_WP or "";

  mkLockScript = { grace ? false }: let
    graceArg = lib.optionalString grace "--grace 5";
  in pkgs.writeShellScriptBin "swaylock-lock${lib.optionalString grace "-idle"}" ''
    if [ -f "${lockscreenWp}" ]; then
      exec ${swaylock} -i "${lockscreenWp}" ${graceArg} ${commonArgs}
    else
      exec ${swaylock} --screenshots --effect-scale 0.5 --effect-blur 10x3 ${graceArg} ${commonArgs}
    fi
  '';

  lockScriptBin     = mkLockScript { grace = false; }; # keybind — no grace
  lockScriptIdleBin = mkLockScript { grace = true;  }; # swayidle — 5s grace

  # Skip when hypridle is handling idle/lock (e.g. hyprland uses hyprlock/hypridle)
  enabled = !config.services.hypridle.enable;
in {
  programs.swaylock = lib.mkIf enabled {
    enable = true;
    package = swaylockPkg;
  };

  home.packages = lib.mkIf enabled [ lockScriptBin lockScriptIdleBin pkgs.wlopm ];

  services.swayidle = lib.mkIf enabled {
    enable = true;
    systemdTargets = [ "graphical-session.target" ];
    timeouts =
      # Dim: save brightness
      [
        {
          timeout = 10;
          command = "${brightnessctl} --save";
          resumeCommand = "${brightnessctl} --restore";
        }
      ]
      ++
      # Dim: kbd backlight off
      [
        {
          timeout = 30;
          command = "${brightnessctl} --device '*:kbd_backlight' --save set 0";
          resumeCommand = "${brightnessctl} --device '*:kbd_backlight' --restore";
        }
      ]
      ++
      # Dim: screen 50%
      [
        {
          timeout = 50;
          command = "${brightnessctl} set 50%-";
        }
      ]
      ++
      # Dim: screen another 50%
      [
        {
          timeout = 110;
          command = "${brightnessctl} set 50%-";
        }
      ]
      ++
      # Lock screen
      [
        {
          timeout = lockTime;
          command = "${lockScriptIdleBin}/bin/swaylock-lock-idle";
        }
      ]
      ++
      # Mute mic (after lock)
      (afterLockTimeout {
        timeout = 10;
        command = "${pactl} set-source-mute @DEFAULT_SOURCE@ yes";
        resumeCommand = "${pactl} set-source-mute @DEFAULT_SOURCE@ no";
      })
      ++
      # DPMS off (after lock)
      [
        {
          timeout = lockTime + 100;
          command = "${wlopm} --off '*'";
          resumeCommand = "${wlopm} --on '*'";
        }
      ]
      ++
      # If already locked: dim
      [
        {
          timeout = 30;
          command = "${isLocked} && ${brightnessctl} set 75%-";
        }
      ]
      ++
      # If already locked: DPMS off
      [
        {
          timeout = 60;
          command = "${isLocked} && ${wlopm} --off '*'";
          resumeCommand = "${wlopm} --on '*'";
        }
      ]
      ++
      # If discharging: suspend
      [
        {
          timeout = 900;
          command = "${isDischarging} && systemctl suspend";
        }
      ];
  };
}
