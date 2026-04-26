{...}: {
  wayland.windowManager.mango.settings = {
    # Border (match hyprland: border_size=2, rounding=10)
    borderpx = 2;
    border_radius = 10;

    # Effects (scenefx)
    blur = true;
    blur_params_radius = 6;
    blur_params_num_passes = 2;
    shadows = false;

    # Opacity
    focused_opacity = 1.0;
    unfocused_opacity = 1.0;

    # Animations
    animations = true;
  };
}
