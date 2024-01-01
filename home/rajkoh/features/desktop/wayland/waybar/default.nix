{
  pkgs,
  lib,
  config,
  ...
}: let
  hasSway = config.wayland.windowManager.sway.enable;
  hasHyprland = config.wayland.windowManager.hyprland.enable;
in {
  xdg.configFile."waybar" = {
    source = ./scripts;
    recursive = true;
  };

  # Let it try to start a few more times
  systemd.user.services.waybar = {
    Unit.StartLimitBurst = 30;
  };

  imports = [
    ./theme2.nix
  ];

  programs.waybar = {
    enable = true;
    package = pkgs.waybar.overrideAttrs (oa: {
      mesonFlags = (oa.mesonFlags or []) ++ ["-Dexperimental=true"];
    });

    systemd.enable = true;
  };
}
