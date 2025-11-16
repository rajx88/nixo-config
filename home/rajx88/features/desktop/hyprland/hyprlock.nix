{
  pkgs,
  lib,
  config,
  ...
}: {
  programs.hyprlock = {
    enable = true;
    package = pkgs.hyprlock;
    settings = {
      auth.fingerprint.enabled = true;
      general = {
        hide_cursor = true;
      };
      animations = {
        enabled = true;
        bezier = [
          "easeout,0.5, 1, 0.9, 1"
          "easeoutback,0.34,1.22,0.65,1"
        ];
        animation = [
          "fade, 1, 3, easeout"
          "inputField, 1, 1, easeoutback"
        ];
      };
      background = {
        # path = "$DEFAULT_WP";
        path = "screenshot";
        blur_passes = 3;
      };
      input-field = lib.forEach config.monitors (monitor: {
        monitor = monitor.name;
        dots_size = toString (0.15 * 1.0);
        font_family = config.fontProfiles.regular.name;
        position = "0, -20%";
        fail_text = "";
        outline_thickness = 0;
        inner_color = "rgba(00000000)";
        check_color = "rgba(00000000)";
        fail_color = "rgba(00000000)";
        font_color = "rgb(202, 211, 245)";
      });
      label = lib.flatten (lib.forEach config.monitors (monitor: [
        {
          monitor = monitor.name;
          text = "$TIME";
          font_family = config.fontProfiles.regular.name;
          font_size = toString (builtins.floor (140 * 1.0));
          position = "0 0";
        }
        {
          monitor = monitor.name;
          text = "$FAIL";
          font_family = config.fontProfiles.regular.name;
          font_size = toString (builtins.floor (18 * 1.0));
          position = "0, -40%";
        }
      ]));
    };
  };

  wayland.windowManager.hyprland = {
    settings = {
      bind = let
        hyprlock = lib.getExe config.programs.hyprlock.package;
      in [
        "SUPER,backspace,exec,${hyprlock}"
      ];
    };
  };

  services.hypridle = {
    enable = true;
    settings = let
      isLocked = "pgrep hyprlock";
      isDischarging = "grep Discharging /sys/class/power_supply/BAT{0,1}/status -q";
    in {
      general = {
        lock_cmd = "if ! ${isLocked}; then ${lib.getExe config.programs.hyprlock.package} --grace 5; fi";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
        inhibit_sleep = 3;
      };
      listener = [
        {
          timeout = 10;
          on-timeout = "brightnessctl --save";
          on-resume = "brightnessctl --restore";
        }
        {
          timeout = 30;
          on-timeout = "brightnessctl --device *:kbd_backlight --save set 0";
          on-resume = "brightnessctl --device *:kbd_backlight --restore";
        }
        {
          timeout = 50;
          on-timeout = "brightnessctl set 50%-";
        }
        {
          timeout = 110;
          on-timeout = "brightnessctl set 50%-";
        }
        {
          timeout = 120;
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = 140;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }

        # If already locked
        {
          timeout = 15;
          on-timeout = "if ${isLocked}; then brightnessctl set 75%-; fi";
        }
        {
          timeout = 20;
          on-timeout = "if ${isLocked}; then hyprctl dispatch dpms off; fi";
          on-resume = "hyprctl dispatch dpms on";
        }

        # If discharging
        {
          timeout = 900;
          on-timeout = "if ${isDischarging}; then systemctl suspend; fi";
        }
      ];
    };
  };
}
