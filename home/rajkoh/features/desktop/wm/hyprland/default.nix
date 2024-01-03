{
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan
    ../../_common
    ../../wayland

    ./swaybg.nix

    ./config/basic-binds.nix
    ./config/binds.nix
    ./config/decoration.nix
    ./config/animations.nix
    ./config/monitor.nix
    ./config/windowrules.nix
    ./config/workspace.nix
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
    # xwayland.enable = true;

    # Optional
    # Whether to enable hyprland-session.target on hyprland startup
    systemd = {
      enable = true;
      # Same as default, but stop graphical-session too
      extraCommands = lib.mkBefore [
        # "systemctl --user stop graphical-session.target"
        "systemctl --user stop hyprland-session.target"
        "systemctl --user start hyprland-session.target"
      ];
    };

    settings = {
      general = {
        # See https://wiki.hyprland.org/Configuring/Variables/ for more
        gaps_in = 8;
        gaps_out = 8;
        border_size = 2;
        layout = "dwindle";
      };

      dwindle = {
        # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
        pseudotile = true; # master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
        preserve_split = true; # you probably want this
        split_width_multiplier = 1.35;
      };

      master = {
        # See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
        new_is_master = true;
      };

      input = {
        kb_layout = "us";

        follow_mouse = 2;
        mouse_refocus = false;

        touchpad = {
          natural_scroll = false;
        };

        sensitivity = 0; # -1.0 - 1.0, 0 means no modification.
        force_no_accel = true;
      };

      misc = {
        close_special_on_empty = true;
      };
    };
  };
}
