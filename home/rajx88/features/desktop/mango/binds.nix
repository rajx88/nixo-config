{
  config,
  lib,
  pkgs,
  ...
}: let
  terminal = config.home.sessionVariables.TERM;
  vaultPath = config.home.sessionVariables.VAULT_PATH;
  files = "${pkgs.thunar}/bin/thunar";

  grim = "${pkgs.grim}/bin/grim";
  slurp = "${pkgs.slurp}/bin/slurp";
  wl-copy = "${pkgs.wl-clipboard}/bin/wl-copy";
  screenshot = pkgs.writeShellScript "screenshot" ''
    geom=$(${slurp}) || exit 1
    file=${config.xdg.userDirs.extraConfig.SCRNSHTS}/$(date +%Y-%m-%d_%H-%M-%S).png
    ${grim} -g "$geom" "$file" && ${wl-copy} --type image/png < "$file"
  '';
  pactl = "${pkgs.pulseaudio}/bin/pactl";
  playerctl = "${config.services.playerctld.package}/bin/playerctl";

  notify = "${pkgs.libnotify}/bin/notify-send";
  wgToggle = pkgs.writeShellScript "wg-toggle" ''
    svc=wg-quick-wg0
    if systemctl is-active --quiet $svc; then
      pkexec /etc/wg-switch "$svc" ""
      if ! systemctl is-active --quiet $svc; then
        ${notify} -u normal "VPN" "wg0 stopped 🔓"
      fi
    else
      pkexec /etc/wg-switch "" $svc || exit 1
      ${notify} -u critical "VPN" "wg0 started 🔒"
    fi
  '';
in {
  wayland.windowManager.mango.settings = {
    bind =
      [
        # ── Terminal ──
        "SUPER+SHIFT,t,spawn,${terminal}"

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

        # ── Monitor profile switcher ──
        "SUPER+SHIFT,d,spawn,mprofile-menu"

      ]
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
        "SUPER+SHIFT,p,spawn_shell,${screenshot}"

        # ── WireGuard VPN ──
        "SUPER+SHIFT,v,spawn_shell,${wgToggle}"
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
