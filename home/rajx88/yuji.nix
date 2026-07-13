{
  inputs,
  outputs,
  config,
  ...
}: {
  imports = [
    inputs.nix-barracudavpn.homeManagerModules.proxy
    inputs.nix-barracudavpn.homeManagerModules.ssh-tunnels

    ./global

    ./features/desktop/mango

    ./features/desktop/optional/discord
    ./features/desktop/optional/spotify.nix
    ./features/desktop/optional/signal.nix
    ./features/desktop/optional/ferdium.nix

    ./features/desktop/optional/plexdesktop.nix
    ./features/desktop/optional/fladder.nix
    ./features/desktop/optional/obsidian.nix
    ./features/games/steam.nix

    ./features/desktop/optional/keymapp.nix
    ./features/desktop/optional/brave-origin.nix
    # ./features/desktop/optional/qutebrowser.nix

    # dev
    ./features/dev/jetbrains.nix
    ./features/dev/vscode.nix
    ./features/dev/mise.nix
    ./features/dev/java.nix
    ./features/dev/kubectl.nix
    ./features/dev/gh.nix
    ./features/dev/glab.nix
    ./features/dev/herdr.nix
    ./features/dev/radar.nix
    ./features/dev/postman.nix
    ./features/dev/zed.nix
    ./features/dev/opencode.nix
    ./features/dev/pi-coding-agent.nix
    ./features/dev/omp.nix
    ./features/dev/rtk.nix
    ./features/dev/aws.nix
    ./features/dev/python.nix
    ./features/dev/worktrunk.nix
    ./features/dev/codegraph.nix
    ./features/dev/icm.nix
    ./features/dev/cursor.nix
    ./features/dev/t3code.nix

    ./features/dev/bruno.nix
  ];

  programs.proxy.pac.enable = true;

  services.ssh-tunnels.enable = true;

  monitorProfiles = {
    enable = true;
    default = "home";

    # Dual 4K 120Hz + laptop panel on the right
    profiles.home = {
      monitors = [
        {
          name = "DP-2";
          width = 3840;
          height = 2160;
          preferredMode = false;
          refreshRate = 120;
          bitdepth = 10;
          scale = 1.2;
          position = "0x0";
          workspaces = [1 2 3 4 5];
          layout = "scroller";
          primary = true;
        }
        {
          name = "DP-1";
          width = 3840;
          height = 2160;
          preferredMode = false;
          refreshRate = 120;
          bitdepth = 10;
          scale = 1.2;
          workspaces = [6 7 8 9 10];
          layout = "scroller";
          position = "auto-right";
        }
        {
          name = "eDP-1";
          width = 1920;
          height = 1200;
          preferredMode = true;
          isLaptop = true;
          refreshRate = 60;
          position = "auto";
          workspaces = [];
        }
      ];
      detect = { externalCount = 2; resolutions = ["3840x2160@120"]; };
    };

    # Ultrawide + laptop panel centered below
    profiles.ultrawide = {
      monitors = [
        {
          name = "DP-1";
          width = 3440;
          height = 1440;
          preferredMode = true;
          refreshRate = 60;
          position = "auto";
          workspaces = [1 2 3 4 5];
          layout = "scroller";
          primary = true;
        }
        {
          name = "eDP-1";
          width = 1920;
          height = 1200;
          preferredMode = true;
          isLaptop = true;
          refreshRate = 60;
          position = "center-below";
          workspaces = [6 7 8 9 10];
          layout = "scroller";
        }
      ];
      detect = { resolutions = ["3440x1440"]; };
    };

    # Dual 4K 120Hz + laptop centered below left screen
    profiles.office = {
      monitors = [
        {
          name = "DP-2";
          width = 3840;
          height = 2160;
          preferredMode = false;
          refreshRate = 120;
          bitdepth = 10;
          position = "0x0";
          workspaces = [1 2 3 4 5];
          layout = "scroller";
          primary = true;
        }
        {
          name = "eDP-1";
          width = 1920;
          height = 1200;
          preferredMode = true;
          isLaptop = true;
          refreshRate = 60;
          position = "center-below";
          workspaces = [];
        }
        {
          name = "DP-1";
          width = 3840;
          height = 2160;
          preferredMode = false;
          refreshRate = 120;
          bitdepth = 10;
          workspaces = [6 7 8 9 10];
          layout = "scroller";
          position = "auto-right";
        }
      ];
      detect = { externalCount = 2; resolutions = ["3840x2160@120"]; };
    };

    # Laptop panel only
    profiles.laptop = {
      monitors = [
        {
          name = "eDP-1";
          width = 1920;
          height = 1200;
          preferredMode = true;
          isLaptop = true;
          refreshRate = 60;
          position = "0x0";
          workspaces = [1 2 3 4 5 6 7 8 9 10];
          layout = "scroller";
          primary = true;
        }
      ];
      detect = { externalCount = 0; };
    };
  };
}
