{
  inputs,
  outputs,
  ...
}: {
  imports = [
    ./global

    ./features/desktop/hyprland

    ./features/desktop/optional/discord
    ./features/desktop/optional/spotify.nix

    # not working for some reason
    # ./features/desktop/optional/obsidian.nix
    # ./features/desktop/optional/plexplayer.nix

    ./features/games

    ./features/desktop/optional/keymapp.nix
    ./features/dev/jetbrains-toolbox.nix
    ./features/dev/vscode.nix
    ./features/dev/mise.nix
  ];

  home.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = 1;
    LIBVA_DRIVER_NAME = "nvidia";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    __GL_VRR_ALLOWED = 1;
    WLR_DRM_NO_ATOMIC = 1;
  };

  #  ------   -----   ------
  # | HDMI | | DP-1| | DP-2 |
  #  ------   -----   ------
  monitors = [
    {
      name = "DP-1";
      width = 2560;
      height = 1440;
      refreshRate = 240;
      workspace = "2";
      position = "0x0";
      primary = true;
    }
    # vertical setup
    # {
    #   name = "HDMI-A-1";
    #   width = 1440;
    #   height = 2560;
    #   refreshRate = 144;
    #   position = "auto-left";
    #   workspace = "1";
    #   vertical = "1";
    # }
    {
      name = "HDMI-A-1";
      width = 2560;
      height = 1440;
      # width = 1440;
      # height = 2560;
      refreshRate = 60;
      position = "auto-left";
      # vertical = "1";
      workspace = "1";
    }

    {
      name = "DP-2";
      width = 2560;
      height = 1440;
      # width = 1440;
      # height = 2560;
      refreshRate = 144;
      position = "auto-right";
      vertical = "3";
      workspace = "3";
    }
  ];
}
