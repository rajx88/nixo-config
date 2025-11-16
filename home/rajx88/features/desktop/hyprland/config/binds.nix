{
  pkgs,
  config,
  lib,
  ...
}: {
  wayland.windowManager.hyprland.settings = {
    "$mod" = "SUPER";

    bind = let
      swaylock = "${config.programs.swaylock.package}/bin/swaylock";
      hyprlock = "${config.programs.hyprlock.package}/bin/hyprlock";

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

      files = "${pkgs.xfce.thunar}/bin/thunar";
      # Launch 1Password via its desktop entry so we don't pin a store path.
      # Prefer the beta GUI if configured; rely on PATH fallback if desktop entry missing.
      # Desktop entry name is typically "1password".
      passman = "${gtk-launch} 1password || 1password";
    in
      [
        # Program bindings
        "$mod,Return,exec,${terminal}"
        "$mod,v,exec,${editor}"
        "$mod,b,exec,${browser}"
        "$mod,e,exec,${files}"
        "$mod,p,exec,${passman}"

        # Volume
        ",XF86AudioRaiseVolume,exec,${pactl} set-sink-volume @DEFAULT_SINK@ +5%"
        ",XF86AudioLowerVolume,exec,${pactl} set-sink-volume @DEFAULT_SINK@ -5%"
        ",XF86AudioMute,exec,${pactl} set-sink-mute @DEFAULT_SINK@ toggle"
        "SHIFT,XF86AudioMute,exec,${pactl} set-source-mute @DEFAULT_SOURCE@ toggle"
        ",XF86AudioMicMute,exec,${pactl} set-source-mute @DEFAULT_SOURCE@ toggle"
        # Screenshotting
        "$mod SHIFT,p,exec,${grim} -t jpeg -g \"$(slurp)\" ${config.xdg.userDirs.extraConfig.XDG_SCRNSHTS_DIR}/$(date +%Y-%m-%d_%H-%m-%s).jpg"
      ]
      ++ (lib.optionals config.services.playerctld.enable [
        # Media control
        ",XF86AudioNext,exec,${playerctl} next"
        ",XF86AudioPrev,exec,${playerctl} previous"
        ",XF86AudioPlay,exec,${playerctl} play-pause"
        ",XF86AudioStop,exec,${playerctl} stop"
      ])
      ++
      # Launcher
      (lib.optionals config.programs.fuzzel.enable [
        "$mod,d,exec,${fuzzel}"
      ])
      ++ [
        # reload waybar
        "$mod SHIFT,w,exec,systemctl --user restart waybar"
      ];
  };
}
