{
  inputs,
  outputs,
  ...
}: {
  imports = [
    ./global

    ./features/desktop/mango

    ./features/desktop/optional/discord
    ./features/desktop/optional/spotify.nix
    ./features/desktop/optional/signal.nix
    ./features/desktop/optional/ferdium.nix

    ./features/games
    ./features/desktop/optional/plexdesktop.nix
    ./features/desktop/optional/obsidian.nix
    ./features/games/steam.nix

    ./features/desktop/optional/keymapp.nix
    ./features/desktop/optional/brave-origin.nix

    # dev
    ./features/dev/jetbrains.nix
    ./features/dev/vscode.nix
    ./features/dev/mise.nix
    ./features/dev/java.nix
    ./features/dev/kubectl.nix
    ./features/dev/gh.nix
    ./features/dev/glab.nix
    ./features/dev/zed.nix
    ./features/dev/opencode.nix
    ./features/dev/pi-coding-agent.nix
    # ./features/dev/claude.nix # temporarily disabled
    ./features/dev/rtk.nix
    ./features/dev/python.nix
    ./features/dev/worktrunk.nix
    ./features/dev/codegraph.nix

    ./features/dev/bruno.nix
  ];

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
          refreshRate = 120;
          bitdepth = 10;
          # scale = 1.25;
          position = "0x0";
          workspaces = [1 2 3 4 5];
          layout = "scroller";
          primary = true;
        }
        {
          name = "DP-1";
          width = 3840;
          height = 2160;
          refreshRate = 120;
          bitdepth = 10;
          # scale = 1.25;
          workspaces = [6 7 8 9 10];
          layout = "scroller";
          position = "3840x0";
        }
      ];
    };
  };
}
