{
  config,
  lib,
  pkgs,
  ...
}: let
  terminal = config.home.sessionVariables.TERM;
  vaultPath = "${config.home.homeDirectory}/code/prvt/github/second-brain";
  files = "${pkgs.thunar}/bin/thunar";

  monitors = config.monitors;
  wsToKey = ws: if ws == 10 then "0" else toString ws;

  grim = "${pkgs.grim}/bin/grim";
  slurp = "${pkgs.slurp}/bin/slurp";
  wl-copy = "${pkgs.wl-clipboard}/bin/wl-copy";
  pactl = "${pkgs.pulseaudio}/bin/pactl";
  playerctl = "${config.services.playerctld.package}/bin/playerctl";
in {
  wayland.windowManager.mango.settings = {
    bind =
      [
        # ── Terminal ──
        "SUPER,Return,spawn,${terminal}"

        # ── App speed dial ──
        "SUPER+SHIFT,b,spawn_shell,$BROWSER"
        "SUPER+SHIFT,e,spawn,${files}"
        "SUPER+SHIFT,slash,spawn,1password"

        # ── Core WM ──
        "SUPER+SHIFT,q,killclient"
        "SUPER,f,togglemaximizescreen"
        "SUPER+SHIFT,f,togglefullscreen"
        "SUPER+SHIFT,space,togglefloating"
        "SUPER,s,zoom"
        "SUPER,Tab,toggleoverview"
        "SUPER,r,reload_config"

        # ── Layouts (dedicated keys) ──
        "SUPER,n,setlayout,scroller"
        "SUPER,m,setlayout,tile"
        "SUPER,comma,setlayout,right_tile"
        "SUPER,period,setlayout,tgmix"

      ]
      # ── Per-monitor tag binds (from config.monitors) ──
      ++ lib.concatMap (m:
        map (ws: "SUPER,${wsToKey ws},viewcrossmon,${toString ws},${m.name}") m.workspaces
        ++ map (ws: "SUPER+SHIFT,${wsToKey ws},tagcrossmon,${toString ws},${m.name}") m.workspaces
      ) (lib.filter (m: m.workspaces != []) monitors)
      ++ [

        # ── Focus direction ──
        "SUPER,Left,focusdir,left"
        "SUPER,Right,focusdir,right"
        "SUPER,Up,focusdir,up"
        "SUPER,Down,focusdir,down"
        "SUPER,h,focusdir,left"
        "SUPER,l,focusdir,right"
        "SUPER,k,focusdir,up"
        "SUPER,j,focusdir,down"

        # ── Swap windows ──
        "SUPER+SHIFT,Left,exchange_client,left"
        "SUPER+SHIFT,Right,exchange_client,right"
        "SUPER+SHIFT,Up,exchange_client,up"
        "SUPER+SHIFT,Down,exchange_client,down"
        "SUPER+SHIFT,h,exchange_client,left"
        "SUPER+SHIFT,l,exchange_client,right"
        "SUPER+SHIFT,k,exchange_client,up"
        "SUPER+SHIFT,j,exchange_client,down"

        # ── Monitor focus ──
        "SUPER+ALT,Left,focusmon,left"
        "SUPER+ALT,Right,focusmon,right"
        "SUPER+ALT,h,focusmon,left"
        "SUPER+ALT,l,focusmon,right"

        # ── Move client to monitor ──
        "SUPER+ALT+SHIFT,Left,tagmon,left"
        "SUPER+ALT+SHIFT,Right,tagmon,right"
        "SUPER+ALT+SHIFT,h,tagmon,left"
        "SUPER+ALT+SHIFT,l,tagmon,right"

        # ── Resize (scroller proportion presets) ──
        "SUPER,minus,switch_proportion_preset,prev"
        "SUPER,equal,switch_proportion_preset,next"

        # ── Scratchpads ──
        "SUPER,u,toggle_scratchpad"
        "SUPER+SHIFT,u,minimized"
        "SUPER+SHIFT,n,toggle_named_scratchpad,scratchpad.notes,none,ghostty --class=scratchpad.notes -e zsh -ic 'nvim ${vaultPath}'"
        "SUPER+SHIFT,m,toggle_named_scratchpad,scratchpad.todo,none,ghostty --class=scratchpad.todo -e zsh -ic 'nvim ${vaultPath}/scratchpad.md'"

        # ── Noctalia ──
        "SUPER,space,spawn,noctalia-shell ipc call launcher toggle"
        "SUPER+SHIFT,w,spawn,noctalia-shell ipc call controlCenter toggle"
        "SUPER,Escape,spawn,noctalia-shell ipc call sessionMenu toggle"
        "SUPER,backspace,spawn,swaylock-lock"

        # ── Volume ──
        "NONE,XF86AudioRaiseVolume,spawn,${pactl} set-sink-volume @DEFAULT_SINK@ +5%"
        "NONE,XF86AudioLowerVolume,spawn,${pactl} set-sink-volume @DEFAULT_SINK@ -5%"
        "NONE,XF86AudioMute,spawn,${pactl} set-sink-mute @DEFAULT_SINK@ toggle"
        "SHIFT,XF86AudioMute,spawn,${pactl} set-source-mute @DEFAULT_SOURCE@ toggle"
        "NONE,XF86AudioMicMute,spawn,${pactl} set-source-mute @DEFAULT_SOURCE@ toggle"

        # ── Screenshot ──
        "SUPER+SHIFT,p,spawn_shell,${grim} -g \"$(${slurp})\" - | tee ${config.xdg.userDirs.extraConfig.SCRNSHTS}/$(date +%Y-%m-%d_%H-%m-%s).png | ${wl-copy} --type image/png"
      ]
      ++ (lib.optionals config.services.playerctld.enable [
        "NONE,XF86AudioNext,spawn,${playerctl} next"
        "NONE,XF86AudioPrev,spawn,${playerctl} previous"
        "NONE,XF86AudioPlay,spawn,${playerctl} play-pause"
        "NONE,XF86AudioStop,spawn,${playerctl} stop"
      ]);

    mousebind = [
      "SUPER,btn_left,moveresize,curmove"
      "SUPER,btn_right,moveresize,curresize"
    ];
  };
}
