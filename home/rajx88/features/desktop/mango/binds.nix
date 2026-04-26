{
  config,
  lib,
  pkgs,
  ...
}: let
  terminal = config.home.sessionVariables.TERM;
  gtk-launch = "${pkgs.gtk3}/bin/gtk-launch";
  xdg-mime = "${pkgs.xdg-utils}/bin/xdg-mime";
  defaultApp = type: "${gtk-launch} $(${xdg-mime} query default ${type})";
  browser = defaultApp "x-scheme-handler/https";
  editor = defaultApp "text/plain";
  files = "${pkgs.thunar}/bin/thunar";
  passman = "${gtk-launch} 1password || 1password";

  grim = "${pkgs.grim}/bin/grim";
  slurp = "${pkgs.slurp}/bin/slurp";
  wl-copy = "${pkgs.wl-clipboard}/bin/wl-copy";
  pactl = "${pkgs.pulseaudio}/bin/pactl";
  playerctl = "${config.services.playerctld.package}/bin/playerctl";
in {
  wayland.windowManager.mango.settings = {
    bind = [
      # Window management
      "SUPER+SHIFT,q,killclient"
      "SUPER+SHIFT,space,togglefloating"
      "SUPER+SHIFT,f,togglefullscreen"
      "SUPER,s,zoom"

      # App launchers
      "SUPER,t,spawn,${terminal}"
      "SUPER,v,spawn,${editor}"
      "SUPER,b,spawn,${browser}"
      "SUPER,e,spawn,${files}"
      "SUPER,p,spawn,${passman}"

      # Noctalia IPC
      "SUPER,space,spawn,noctalia-shell ipc call launcher toggle"
      "SUPER+SHIFT,w,spawn,noctalia-shell ipc call controlCenter toggle"
      "SUPER,Escape,spawn,noctalia-shell ipc call sessionMenu toggle"

      # Lock screen via noctalia
      "SUPER,backspace,spawn,noctalia-shell ipc call lockScreen lock"

      # Volume
      ",XF86AudioRaiseVolume,spawn,${pactl} set-sink-volume @DEFAULT_SINK@ +5%"
      ",XF86AudioLowerVolume,spawn,${pactl} set-sink-volume @DEFAULT_SINK@ -5%"
      ",XF86AudioMute,spawn,${pactl} set-sink-mute @DEFAULT_SINK@ toggle"
      "SHIFT,XF86AudioMute,spawn,${pactl} set-source-mute @DEFAULT_SOURCE@ toggle"
      ",XF86AudioMicMute,spawn,${pactl} set-source-mute @DEFAULT_SOURCE@ toggle"

      # Screenshot
      "SUPER+SHIFT,p,spawn_shell,${grim} -g \"$(${slurp})\" - | tee ${config.xdg.userDirs.extraConfig.SCRNSHTS}/$(date +%Y-%m-%d_%H-%m-%s).png | ${wl-copy} --type image/png"

      # Focus (arrows + hjkl)
      "SUPER,Left,focusdir,left"
      "SUPER,Right,focusdir,right"
      "SUPER,Up,focusdir,up"
      "SUPER,Down,focusdir,down"
      "SUPER,h,focusdir,left"
      "SUPER,l,focusdir,right"
      "SUPER,k,focusdir,up"
      "SUPER,j,focusdir,down"

      # Swap windows
      "SUPER+SHIFT,Left,exchange_client,left"
      "SUPER+SHIFT,Right,exchange_client,right"
      "SUPER+SHIFT,Up,exchange_client,up"
      "SUPER+SHIFT,Down,exchange_client,down"
      "SUPER+SHIFT,h,exchange_client,left"
      "SUPER+SHIFT,l,exchange_client,right"
      "SUPER+SHIFT,k,exchange_client,up"
      "SUPER+SHIFT,j,exchange_client,down"

      # Monitor focus
      "SUPER+ALT,Left,focusmon,left"
      "SUPER+ALT,Right,focusmon,right"
      "SUPER+ALT,h,focusmon,left"
      "SUPER+ALT,l,focusmon,right"

      # Move client to monitor
      "SUPER+ALT+SHIFT,Left,tagmon,left"
      "SUPER+ALT+SHIFT,Right,tagmon,right"
      "SUPER+ALT+SHIFT,h,tagmon,left"
      "SUPER+ALT+SHIFT,l,tagmon,right"

      # Overview
      "SUPER,Tab,toggleoverview"

      # Scratchpad
      "SUPER,z,toggle_scratchpad"

      # Resize master
      "SUPER,minus,setmfact,-0.05"
      "SUPER,equal,setmfact,+0.05"

      # Cycle layouts
      "SUPER,n,switch_layout"

      # Tags 1-9 (view) — mango tags are 1-indexed
      "CTRL,1,view,1"
      "CTRL,2,view,2"
      "CTRL,3,view,3"
      "CTRL,4,view,4"
      "CTRL,5,view,5"
      "CTRL,6,view,6"
      "CTRL,7,view,7"
      "CTRL,8,view,8"
      "CTRL,9,view,9"

      # Move client to tag 1-9
      "SUPER,1,tag,1"
      "SUPER,2,tag,2"
      "SUPER,3,tag,3"
      "SUPER,4,tag,4"
      "SUPER,5,tag,5"
      "SUPER,6,tag,6"
      "SUPER,7,tag,7"
      "SUPER,8,tag,8"
      "SUPER,9,tag,9"
    ]
    ++ (lib.optionals config.services.playerctld.enable [
      ",XF86AudioNext,spawn,${playerctl} next"
      ",XF86AudioPrev,spawn,${playerctl} previous"
      ",XF86AudioPlay,spawn,${playerctl} play-pause"
      ",XF86AudioStop,spawn,${playerctl} stop"
    ]);

    mousebind = [
      "SUPER,btn_left,moveresize,curmove"
      "SUPER,btn_right,moveresize,curresize"
    ];
  };
}
