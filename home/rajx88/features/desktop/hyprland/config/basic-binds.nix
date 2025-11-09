{lib, ...}: {
  wayland.windowManager.hyprland.settings = {
    "$mod" = "SUPER";
    bindm = [
      "$mod,mouse:272,movewindow"
      "$mod,mouse:273,resizewindow"
    ];

    bind = let
      workspaces = [
        "0"
        "1"
        "2"
        "3"
        "4"
        "5"
        "6"
        "7"
        "8"
        "9"
        "F1"
        "F2"
        "F3"
        "F4"
        "F5"
        "F6"
        "F7"
        "F8"
        "F9"
        "F10"
        "F11"
        "F12"
      ];
      # Map keys (arrows and hjkl) to hyprland directions (l, r, u, d)
      directions = rec {
        left = "l";
        right = "r";
        up = "u";
        down = "d";
        h = left;
        l = right;
        k = up;
        j = down;
      };
    in
      [
        "$mod SHIFT,q,killactive"

        "$mod,s,togglesplit"
        "$mod,f,fullscreen,1"
        "$mod SHIFT,f,fullscreen,0"
        "$mod SHIFT,space,togglefloating"

        "$mod,minus,splitratio,-0.25"

        "$mod,equal,splitratio,0.25"

        "$mod,g,togglegroup"
        "$mod,t,lockactivegroup,toggle"
        "$mod,apostrophe,changegroupactive,f"
        "$mod SHIFT,apostrophe,changegroupactive,b"

        "$mod,u,togglespecialworkspace"
        "$mod SHIFT,u,movetoworkspacesilent,special"
      ]
      ++
      # Change workspace
      (map (
          n: "$mod,${n},workspace,name:${n}"
        )
        workspaces)
      ++
      # Move window to workspace
      (map (
          n: "$mod SHIFT,${n},movetoworkspacesilent,name:${n}"
        )
        workspaces)
      ++
      # Move focus
      (lib.mapAttrsToList (
          key: direction: "$mod,${key},movefocus,${direction}"
        )
        directions)
      ++
      # Swap windows
      (lib.mapAttrsToList (
          key: direction: "$mod SHIFT,${key},swapwindow,${direction}"
        )
        directions)
      ++
      # Move windows
      (lib.mapAttrsToList (
          key: direction: "$mod CONTROL,${key},movewindoworgroup,${direction}"
        )
        directions)
      ++
      # Move monitor focus
      (lib.mapAttrsToList (
          key: direction: "$mod ALT,${key},focusmonitor,${direction}"
        )
        directions)
      ++
      # Move workspace to other monitor
      (lib.mapAttrsToList (
          key: direction: "$mod ALT SHIFT,${key},movecurrentworkspacetomonitor,${direction}"
        )
        directions);
  };
}
