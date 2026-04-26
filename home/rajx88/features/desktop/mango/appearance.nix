{...}: {
  wayland.windowManager.mango.settings = {
    # Border (match hyprland: border_size=2, rounding=10)
    border_size = 2;
    border_radius = 10;

    # Effects (scenefx)
    blur = true;
    blur_radius = 6;
    blur_passes = 2;
    shadow = false;

    # Opacity
    active_opacity = 1.0;
    inactive_opacity = 1.0;

    # Animations
    animation = true;
  };
}
