{
  inputs,
  outputs,
  ...
}: {
  imports = [
    ./global

    # ./features/desktop/gnome
    ./features/desktop/hyprland

    # ./features/desktop/optional/obsidian.nix
    ./features/desktop/optional/plexplayer.nix
    ./features/games

    ./features/dev/jetbrains-toolbox.nix
  ];

  home.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    LIBVA_DRIVER_NAME = "nvidia";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    __GL_VRR_ALLOWED = 1;
    WLR_DRM_NO_ATOMIC = 1;
  };

  #  ------   -----   ------
  # | DP-3 | | DP-1| | DP-2 |
  #  ------   -----   ------
  monitors = [
    {
      name = "HDMI-A-1";
      width = 2560;
      height = 1440;
      refreshRate = 60;
      x = 0;
      workspace = "1";
    }
    {
      name = "DP-1";
      width = 2560;
      height = 1440;
      refreshRate = 200;
      x = 2560;
      workspace = "2";
      primary = true;
    }
    {
      name = "DP-2";
      width = 2560;
      height = 1440;
      refreshRate = 200;
      x = 5120;
      workspace = "3";
    }
  ];
}
