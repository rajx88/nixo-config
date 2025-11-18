{
  inputs,
  outputs,
  ...
}: {
  imports = [
    inputs.nix-barracudavpn.homeManagerModules.proxy

    ./global

    ./features/desktop/hyprland

    ./features/desktop/optional/discord
    ./features/desktop/optional/spotify.nix
    ./features/desktop/optional/signal.nix
    ./features/desktop/optional/ferdium.nix
    ./features/desktop/optional/teams.nix

    ./features/desktop/optional/plexdesktop.nix
    ./features/desktop/optional/obsidian.nix

    ./features/desktop/optional/keymapp.nix
    ./features/dev/intellij-ultimate.nix
    ./features/dev/vscode.nix
    ./features/dev/mise.nix
    ./features/dev/java.nix
  ];

  programs.proxy.pac.enable = true;

  home.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = 1;
    LIBVA_DRIVER_NAME = "nvidia";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    __GL_VRR_ALLOWED = 1;
    WLR_DRM_NO_ATOMIC = 1;
    WLR_DRM_DEVICES = "/dev/dri/card1:/dev/dri/card0"; # dGPU first (usually)
    WLR_DRM_DISABLE_MODIFIERS = "1";
    # if it still blacks out on cold boot:
    # WLR_DRM_NO_ATOMIC = "1";
  };

  hyprland.scrolling.enable = true;

  monitors = [
    {
      name = "DP-3";
      width = 3840;
      height = 2160;
      preferredMode = true;
      refreshRate = 60;
      workspaces = [6 7 8 9 0];
      position = "auto-right";
      # primary = true;
    }
    {
      name = "DP-5";
      width = 3840;
      height = 2160;
      preferredMode = true;
      refreshRate = 60;
      position = "auto-left";
      workspaces = [1 2 3 4 5];
      primary = true;
    }
    {
      name = "eDP-1";
      width = 1920;
      height = 1200;
      preferredMode = true;
      isLaptop = true;
      refreshRate = 60;
      position = "auto";
    }
  ];
}
