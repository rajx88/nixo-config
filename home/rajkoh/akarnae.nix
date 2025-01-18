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
    ./features/desktop/optional/whatsapp.nix
    ./features/desktop/optional/thunderbird.nix
    ./features/desktop/optional/keyring.nix

    # not working for some reason
    # ./features/desktop/optional/obsidian.nix
    # ./features/desktop/optional/plexplayer.nix

    ./features/games

    # ./features/pass

    ./features/desktop/optional/keymapp.nix
    ./features/dev/jetbrains-toolbox.nix
    ./features/dev/vscode.nix
    ./features/dev/asdf.nix
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
  # | HDMI | | DP-2| | DP-1 |
  #  ------   -----   ------
  monitors = [
    {
      name = "HDMI-A-1";
      width = 2560;
      height = 1440;
      refreshRate = 60;
      x = 0;
      workspace = "2";
    }
    {
      name = "DP-2";
      width = 2560;
      height = 1440;
      refreshRate = 200;
      x = 2560;
      workspace = "1";
      primary = true;
    }
    {
      name = "DP-1";
      width = 2560;
      height = 1440;
      refreshRate = 200;
      x = 5120;
      workspace = "3";
    }
  ];
}
