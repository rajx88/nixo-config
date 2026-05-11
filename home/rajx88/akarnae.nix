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
  monitorProfiles = {
    enable = true;
    default = "desktop";

    profiles.desktop = {
      monitors = [
        {
          name = "DP-2";
          width = 3840;
          height = 2160;
          preferredMode = true;
          refreshRate = 60;
          scale = 1.25;
          position = "auto";
          workspaces = [1 2 3 4 5];
          primary = true;
        }
        {
          name = "DP-1";
          width = 3840;
          height = 2160;
          preferredMode = true;
          refreshRate = 60;
          scale = 1.25;
          position = "auto";
          workspaces = [6 7 8 9 10];
        }
      ];
    };
  };
}
