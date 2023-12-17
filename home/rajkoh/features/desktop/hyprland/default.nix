{
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan
    ../_common
    ../_common/wayland

    ./basic-binds.nix
  ];

  xdg.portal = {
    extraPortals = [pkgs.inputs.hyprland.xdg-desktop-portal-hyprland];
    configPackages = [pkgs.inputs.hyprland.hyprland];
  };

  wayland.windowManager.hyprland = {
    # Whether to enable Hyprland wayland compositor
    enable = true;
    # The hyprland package to use
    package = pkgs.inputs.hyprland.hyprland;
    # Whether to enable XWayland
    xwayland.enable = true;

    # Optional
    # Whether to enable hyprland-session.target on hyprland startup
    systemd = {
      enable = true;
      # Same as default, but stop graphical-session too
      #      extraCommands = lib.mkBefore [
      #        "systemctl --user stop graphical-session.target"
      #        "systemctl --user start hyprland-session.target"
      #      ];
    };
    # Whether to enable patching wlroots for better Nvidia support
    # TODO: set this with an if statement
    # enableNvidiaPatches = true;

    settings = {
      monitor = map (
        m: let
          resolution = "${toString m.width}x${toString m.height}@${toString m.refreshRate}";
          position = "${toString m.x}x${toString m.y}";
        in "${m.name},${
          if m.enabled
          then "${resolution},${position},1"
          else "disable"
        }"
      ) (config.monitors);

      workspace = map (
        m: "${m.name},${m.workspace}"
      ) (lib.filter (m: m.enabled && m.workspace != null) config.monitors);
    };
  };
}
