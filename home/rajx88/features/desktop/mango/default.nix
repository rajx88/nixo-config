{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.mango.hmModules.mango

    ../_common
    ../_common/wayland

    ./binds.nix
    ./monitor.nix
    ./lid.nix
  ];

  wayland.windowManager.mango = {
    enable = true;

    settings = {
      # Input
      repeat_rate = 25;
      repeat_delay = 600;
      xkb_rules_layout = "us";
      tap_to_click = true;
      trackpad_natural_scrolling = false;
      accel_profile = 0;

      # Focus
      sloppyfocus = true;
      warpcursor = true;

      # Layouts
      circle_layout = "tile,scroller";
    };

    autostart_sh = ''
      noctalia-shell &
      ${pkgs.lxqt.lxqt-policykit}/bin/lxqt-policykit-agent &
    '';

    systemd.enable = true;
  };

  # Noctalia idle + lock (hyprland uses hyprlock/hypridle instead)
  programs.noctalia-shell.settings = {
    general = {
      allowPasswordWithFprintd = true;
      lockScreenBlur = 20;
      lockScreenTint = 0.3;
      lockOnSuspend = true;
      clockFormat = "HH\nmm";
    };
    idle = {
      enabled = true;
      screenOffTimeout = 300;
      lockTimeout = 660;
      suspendTimeout = 900;
      fadeDuration = 5;
    };
  };
}
