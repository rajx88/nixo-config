{pkgs, ...}: {
  wayland.windowManager.hyprland = {
    plugins = [
      pkgs.hyprlandPlugins.hyprscrolling
    ];

    settings = {
      "$mod" = "SUPER";
      general = {
        layout = "scrolling";
      };
      plugin = {
        hyprscrolling = {
          fullscreen_on_one_column = true;
          column_width = 0.5;
          explicit_column_widths = "0.333, 0.5, 0.667, 1.0";
          focus_fit_method = 1; # 0 = center, 1 = fit
          follow_focus = true;
        };
      };
      bind = [
        "$mod, period, layoutmsg, move +col"
        "$mod, comma, layoutmsg, move -col"
        "$mod SHIFT, period, layoutmsg, movewindowto r"
        "$mod SHIFT, comma, layoutmsg, movewindowto l"

        "$mod, f, layoutmsg, colresize 1.0"
        "$mod, r, layoutmsg, colresize +conf"
        "$mod, s, layoutmsg, colresize 0.5"
      ];
    };
  };
}
