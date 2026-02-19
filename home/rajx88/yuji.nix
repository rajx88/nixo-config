{
  inputs,
  outputs,
  ...
}: {
  imports = [
    inputs.nix-barracudavpn.homeManagerModules.proxy
    inputs.nix-barracudavpn.homeManagerModules.ssh-tunnels

    ./global

    ./features/desktop/hyprland

    ./features/desktop/optional/discord
    ./features/desktop/optional/spotify.nix
    ./features/desktop/optional/signal.nix
    ./features/desktop/optional/ferdium.nix

    ./features/desktop/optional/plexdesktop.nix
    ./features/desktop/optional/obsidian.nix
    ./features/games/steam.nix

    ./features/desktop/optional/keymapp.nix

    # dev
    ./features/dev/intellij-ultimate.nix
    ./features/dev/vscode.nix
    ./features/dev/mise.nix
    ./features/dev/java.nix
    ./features/dev/kubectl.nix
    ./features/dev/postman.nix
    ./features/dev/zed.nix
    ./features/dev/opencode.nix
    ./features/dev/aws.nix

    # ./features/dev/bruno.nix
  ];

  programs.proxy.pac.enable = true;

  services.ssh-tunnels.enable = true;

  home.sessionVariables = {
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    LIBVA_DRIVER_NAME = "nvidia"; # if you installed nvidia-vaapi-driver
    GBM_BACKEND = "nvidia-drm";
    __GL_VRR_ALLOWED = "1";
    # WLR_NO_HARDWARE_CURSORS = "1"; # drop this if everything works fine
  };

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
      position = "auto-center-down";
      workspaces = [6 7 8 9 0];
    }
    {
      name = "DP-1";
      width = 3840;
      height = 2160;
      preferredMode = true;
      refreshRate = 60;
      position = "auto-center-up";
      workspaces = [1 2 3 4 5];
    }
  ];
}
