{
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan
    ../_common
    ../wayland

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
    # xwayland.enable = true;

    # Optional
    # Whether to enable hyprland-session.target on hyprland startup
    systemd = {
      enable = true;
      # Same as default, but stop graphical-session too
      extraCommands = lib.mkBefore [
        "systemctl --user stop graphical-session.target"
        "systemctl --user start hyprland-session.target"
      ];
    };
    # Whether to enable patching wlroots for better Nvidia support
    # TODO: set this with an if statement
    # enableNvidiaPatches = true;

    settings = {
      windowrulev2 = [
        "float, class:^ (leagueclientux.exe)$,title:^ (League of Legends)$"
        "size 2560 1440,class:^ (league of legends.exe)$"
        "fullscreen,class:^ (league of legends.exe)$"
        "nofullscreenrequest, class:^(cs2)$"
        "nomaximizerequest, class:^(cs2)$"
      ];

      windowrule = [
        "size 1280 720,^ (leagueclientux.exe)$"
        "center,^ (leagueclientux.exe)$"
      ];

      general = {
        # See https://wiki.hyprland.org/Configuring/Variables/ for more

        gaps_in = 8;
        gaps_out = 8;
        border_size = 2;
        layout = "dwindle";
        # layout = "master";
      };

      input = {
        kb_layout = "us";

        follow_mouse = 2;
        mouse_refocus = false;

        # touchpad = {
        #   natural_scroll = false;
        # };

        sensitivity = 0; # -1.0 - 1.0, 0 means no modification.    }
      };

      misc = {
        close_special_on_empty = true;
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

      decoration = {
        rounding = 10;
        blur = {
          enabled = true;
          size = 6;
          passes = 2;
          new_optimizations = true;
          ignore_opacity = true;
          xray = true;
          # blurls = waybar
        };
        active_opacity = 0.95;
        inactive_opacity = 0.8;
        fullscreen_opacity = 1.0;

        drop_shadow = true;
        shadow_range = 30;
        shadow_render_power = 3;
        "col.shadow" = "0x66000000";
      };

      bind = let
        swaylock = "${config.programs.swaylock.package}/bin/swaylock";

        fuzzel = "${config.programs.fuzzel.package}/bin/fuzzel";

        playerctl = "${config.services.playerctld.package}/bin/playerctl";
        playerctld = "${config.services.playerctld.package}/bin/playerctld";

        grim = "${pkgs.grim}/bin/grim";
        slurp = "${pkgs.slurp}/bin/slurp";
        pactl = "${pkgs.pulseaudio}/bin/pactl";

        gtk-launch = "${pkgs.gtk3}/bin/gtk-launch";
        xdg-mime = "${pkgs.xdg-utils}/bin/xdg-mime";
        defaultApp = type: "${gtk-launch} $(${xdg-mime} query default ${type})";

        terminal = config.home.sessionVariables.TERM;
        browser = defaultApp "x-scheme-handler/https";
        editor = defaultApp "text/plain";
      in
        [
          # Program bindings
          "SUPER,Return,exec,${terminal}"
          "SUPER,v,exec,${editor}"
          "SUPER,b,exec,${browser}"

          # Volume
          ",XF86AudioRaiseVolume,exec,${pactl} set-sink-volume @DEFAULT_SINK@ +5%"
          ",XF86AudioLowerVolume,exec,${pactl} set-sink-volume @DEFAULT_SINK@ -5%"
          ",XF86AudioMute,exec,${pactl} set-sink-mute @DEFAULT_SINK@ toggle"
          "SHIFT,XF86AudioMute,exec,${pactl} set-source-mute @DEFAULT_SOURCE@ toggle"
          ",XF86AudioMicMute,exec,${pactl} set-source-mute @DEFAULT_SOURCE@ toggle"
          # Screenshotting
          "SUPERSHIFT,s,exec,${grim} -t jpeg -g ${slurp} ~/screenshots/$(date +%Y-%m-%d_%H-%m-%s).jpg"
        ]
        ++ (lib.optionals config.services.playerctld.enable [
          # Media control
          ",XF86AudioNext,exec,${playerctl} next"
          ",XF86AudioPrev,exec,${playerctl} previous"
          ",XF86AudioPlay,exec,${playerctl} play-pause"
          ",XF86AudioStop,exec,${playerctl} stop"
        ])
        ++
        # Screen lock
        (lib.optionals config.programs.swaylock.enable [
          # "SUPER,backspace,exec,${swaylock} -S --grace 2"
          "SUPER,backspace,exec,${swaylock} --grace 2 --clock --indicator --screenshots --effect-scale 0.4 --effect-vignette 0.2:0.5 --effect-blur 4x2 --datestr '%a %e.%m.%Y' --timestr '%k:%M'"
        ])
        ++
        # Launcher
        (lib.optionals config.programs.fuzzel.enable [
          "SUPER,d,exec,${fuzzel}"
        ]);

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
