{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    inputs.mango.hmModules.mango

    ../_common
    ../_common/wayland

    ./binds.nix
    ./monitor.nix
    ./appearance.nix
    ./lid.nix
  ];

  xdg.portal = {
    extraPortals = [pkgs.xdg-desktop-portal-wlr];
    configPackages = [config.wayland.windowManager.mango.package];
  };

  wayland.windowManager.mango = {
    enable = true;

    settings = {
      # Input
      repeat_rate = 25;
      repeat_delay = 600;
      kb_layout = "us";
      tap_to_click = true;
      natural_scroll = false;
      force_no_accel = true;

      # Misc
      xwayland = true;
      sloppy_focus = true;
      warp_cursor = true;

      # Gaps (match hyprland: gaps_in=8, gaps_out=8)
      gappih = 8;
      gappiv = 8;
      gappoh = 8;
      gappov = 8;

      # Layouts
      circle_layout = "tile,scroller";
    };

    autostart_sh = ''
      noctalia-shell &
      ${pkgs.lxqt.lxqt-policykit}/bin/lxqt-policykit-agent &
    '';

    systemd.enable = true;
  };

  # Noctalia idle + lock config for mango
  # (Hyprland uses hyprlock/hypridle instead)
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
