{
  pkgs,
  config,
  lib,
  ...
}: let
  vaultPath = "${config.home.homeDirectory}/code/prvt/github/second-brain";

  notesScript = pkgs.writeShellScriptBin "notes-scratchpad" ''
    if ! hyprctl clients -j | ${pkgs.jq}/bin/jq -e '.[] | select(.workspace.name=="special:notes")' > /dev/null 2>&1; then
      ghostty --class=notes -e nvim "${vaultPath}" &
      sleep 0.3
    fi
    hyprctl dispatch togglespecialworkspace notes
  '';

  todoScript = pkgs.writeShellScriptBin "todo-scratchpad" ''
    if ! hyprctl clients -j | ${pkgs.jq}/bin/jq -e '.[] | select(.workspace.name=="special:todo")' > /dev/null 2>&1; then
      ghostty --class=todo -e nvim "${vaultPath}/0300-todos/todo.md" &
      sleep 0.3
    fi
    hyprctl dispatch togglespecialworkspace todo
  '';
in {
  home.packages = [ notesScript todoScript ];

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
      wl-copy = "${pkgs.wl-clipboard}/bin/wl-copy";
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
        "$mod SHIFT,p,exec,${grim} -g \"$(${slurp})\" - | tee ${config.xdg.userDirs.extraConfig.SCRNSHTS}/$(date +%Y-%m-%d_%H-%m-%s).png | ${wl-copy} --type image/png"
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

        # Notes scratchpad: nvim in vault root
        "$mod,n,exec,notes-scratchpad"
        # Todo scratchpad: nvim with todo.md
        "$mod,m,exec,todo-scratchpad"
      ];
  };
}
