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
    # ./features/desktop/optional/obsidian.nix
    # ./features/desktop/optional/plexplayer.nix

    ./features/games

    ./features/desktop/optional/keymapp.nix
    # ./features/dev/jetbrains-toolbox.nix
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

  monitors = [
    {
      name = "DP-3";
      width = 3840;
      height = 2160;
      refreshRate = 60;
      workspace = "2";
      position = "auto-right";
    }
    {
      name = "DP-5";
      width = 3840;
      height = 2160;
      refreshRate = 60;
      position = "auto-left";
      workspace = "1";
      primary = true;
    }
  ];
}
