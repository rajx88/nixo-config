{
  pkgs,
  lib,
  config,
  ...
}: let
  swaylock = "${config.programs.swaylock.package}/bin/swaylock";
  pgrep = "${pkgs.procps}/bin/pgrep";
  pactl = "${pkgs.pulseaudio}/bin/pactl";
  hyprctl = "${config.wayland.windowManager.hyprland.package}/bin/hyprctl";

  # pgrep -x fails when given a pattern longer than 15 chars (common with nix store paths).
  # Use -f to match against the full command line (matches the full nix-store path to swaylock).
  isLocked = "${pgrep} -f ${swaylock}";
  lockTime = 10 * 60; # TODO: make this configurable for different hosts

  # Makes two timeouts: one for when the screen is not locked (lockTime+timeout) and one for when it is.
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
in {
  programs.swaylock = {
    enable = true;
    package = pkgs.swaylock-effects;
  };

  # Only inject Hyprland settings if Hyprland is enabled
  lib.optionalAttrs config.wayland.windowManager.hyprland.enable {
    wayland.windowManager.hyprland = {
      settings = {
        bind = let
          swaylock = lib.getExe config.programs.swaylock.package;
        in [
          "$mod,backspace,exec,${swaylock} -i \"$DEFAULT_WP\" --clock --indicator --timestr '%k:%M' --datestr '%a %e.%m.%Y' --daemonize"
        ];
      };
    };
  };

  services.swayidle = {
    enable = true;
    systemdTarget = "graphical-session.target";
    timeouts =
      # Lock screen
      [
        {
          timeout = lockTime;
          # Use swaylock-effects to show a background image and a simple clock/indicator.
          # systemd unit strings need % escaped as %% so the executed command receives a single %
          # Add a gentle blur; if this causes issues on a host, reduce/remove the --effect-blur value.
          command = "${swaylock} -i \"$DEFAULT_WP\" --clock --indicator --timestr '%%k:%%M' --datestr '%%a %%e.%%m.%%Y' --daemonize";
        }
      ]
      ++
      # Mute mic
      (afterLockTimeout {
        timeout = 10;
        command = "${pactl} set-source-mute @DEFAULT_SOURCE@ yes";
        resumeCommand = "${pactl} set-source-mute @DEFAULT_SOURCE@ no";
      })
      ++
      # Turn off displays (hyprland)
      (lib.optionals config.wayland.windowManager.hyprland.enable (afterLockTimeout {
        timeout = 40;
        command = "${hyprctl} dispatch dpms off";
        resumeCommand = "${hyprctl} dispatch dpms on";
      }));
  };
}
