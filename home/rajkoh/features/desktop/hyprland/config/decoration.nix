{
  wayland.windowManager.hyprland.settings = {
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
    };
  };
}
