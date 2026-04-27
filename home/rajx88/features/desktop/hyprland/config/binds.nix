{
  pkgs,
  config,
  lib,
  ...
}: let
  vaultPath = "${config.home.homeDirectory}/code/prvt/github/second-brain";
in {

  wayland.windowManager.hyprland.settings = {
    "$mod" = "SUPER";

    bind = let
      swaylock = "${config.programs.swaylock.package}/bin/swaylock";
      hyprlock = "${config.programs.hyprlock.package}/bin/hyprlock";


      playerctl = "${config.services.playerctld.package}/bin/playerctl";
      playerctld = "${config.services.playerctld.package}/bin/playerctld";

      grim = "${pkgs.grim}/bin/grim";
      slurp = "${pkgs.slurp}/bin/slurp";
      wl-copy = "${pkgs.wl-clipboard}/bin/wl-copy";
      screenshot = pkgs.writeShellScript "screenshot" ''
        geom=$(${slurp}) || exit 1
        file=${config.xdg.userDirs.extraConfig.SCRNSHTS}/$(date +%Y-%m-%d_%H-%M-%S).png
        ${grim} -g "$geom" "$file" && ${wl-copy} --type image/png < "$file"
      '';
      pactl = "${pkgs.pulseaudio}/bin/pactl";

      gtk-launch = "${pkgs.gtk3}/bin/gtk-launch";
      xdg-mime = "${pkgs.xdg-utils}/bin/xdg-mime";
      defaultApp = type: "${gtk-launch} $(${xdg-mime} query default ${type})";

      terminal = config.home.sessionVariables.TERM;
      browser = defaultApp "x-scheme-handler/https";
      editor = defaultApp "text/plain";

      files = "${pkgs.thunar}/bin/thunar";
      # Launch 1Password via its desktop entry so we don't pin a store path.
      # Prefer the beta GUI if configured; rely on PATH fallback if desktop entry missing.
      # Desktop entry name is typically "1password".
      passman = "${gtk-launch} 1password || 1password";
    in
      [
        # Program bindings
        "$mod,t,exec,${terminal}"
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
        "$mod SHIFT,p,exec,${screenshot}"
      ]
      ++ (lib.optionals config.services.playerctld.enable [
        # Media control
        ",XF86AudioNext,exec,${playerctl} next"
        ",XF86AudioPrev,exec,${playerctl} previous"
        ",XF86AudioPlay,exec,${playerctl} play-pause"
        ",XF86AudioStop,exec,${playerctl} stop"
      ])
      ++
      # Launcher — noctalia built-in
      [
        "$mod,space,exec,noctalia-shell ipc call launcher toggle"
      ]
      ++ [
        # noctalia control center
        "$mod SHIFT,w,exec,noctalia-shell ipc call controlCenter toggle"

        # Noctalia session menu (power options)
        "$mod,Escape,exec,noctalia-shell ipc call sessionMenu toggle"

        # Scratchpad toggles
        "$mod,n,togglespecialworkspace,notes"
        "$mod,m,togglespecialworkspace,todo"
      ];
  };
}
