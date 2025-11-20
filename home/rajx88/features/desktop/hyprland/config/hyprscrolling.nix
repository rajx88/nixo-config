{
  pkgs,
  config,
  lib,
  ...
}: {
  options.hyprland.scrolling.enable = lib.mkEnableOption "Enable Hyprland scrolling layout and plugin";

  config = lib.mkIf config.hyprland.scrolling.enable {
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
            explicit_column_widths = "0.333, 0.667";
            focus_fit_method = 1; # 0 = center, 1 = fit
            follow_focus = false;
          };
        };
        bind = [
          # moving columns
          "$mod, period, layoutmsg, move +col"
          "$mod, comma, layoutmsg, move -col"
          "$mod SHIFT, period, layoutmsg, movewindowto r"
          "$mod SHIFT, comma, layoutmsg, movewindowto l"

          "$mod SHIFT, j, layoutmsg, movewindowto u"
          "$mod SHIFT, k, layoutmsg, movewindowto d"

          "$mod SHIFT, h, layoutmsg, swapcol l"
          "$mod SHIFT, l, layoutmsg, swapcol r"

          "$mod, h, layoutmsg, focus l"
          "$mod, l, layoutmsg, focus r"
          "$mod, j, layoutmsg, focus d"
          "$mod, k, layoutmsg, focus u"

          # resizing columns
          "$mod, f, layoutmsg, colresize 1.0"
          "$mod, r, layoutmsg, colresize +conf"
          "$mod, s, layoutmsg, colresize 0.5"
        ];
      };
    };
  };
}
