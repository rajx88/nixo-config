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
    ./features/desktop/optional/signal.nix

    # not working for some reason
    ./features/desktop/optional/obsidian.nix
    ./features/desktop/optional/plexdesktop.nix

    ./features/games

    ./features/desktop/optional/keymapp.nix
    ./features/dev/intellij-ultimate.nix
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
      width = 3840;
      height = 2160;
      preferredMode = true;
      refreshRate = 60;
      workspaces = [6 7 8 9 0];
      position = "auto-right";
      # primary = true;
    }
    {
      name = "DP-2";
      width = 3840;
      height = 2160;
      preferredMode = true;
      refreshRate = 60;
      position = "auto-left";
      workspaces = [1 2 3 4 5];
      primary = true;
    }
  ];
}
