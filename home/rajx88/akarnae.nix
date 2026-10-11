{
  inputs,
  outputs,
  ...
}:
let
  #  ------   -----   ------
  # | HDMI | | DP-1| | DP-2 |
  #  ------   -----   ------
  #
  # Dual-4K layout, parameterised by UI scale.
  #   desktop-120  → 120% UI, the default
  #   desktop      → native 1:1 (100%), kept so it can be switched back
  #                  live with `mprofile set desktop` (or SUPER+SHIFT,D)
  dualDisplay = scale: [
    {
      name = "DP-2";
      width = 3840;
      height = 2160;
      refreshRate = 120;
      bitdepth = 10;
      inherit scale;
      position = "0x0";
      workspaces = [
        1
        2
        3
        4
        5
      ];
      layout = "scroller";
      primary = true;
    }
    {
      name = "DP-1";
      width = 3840;
      height = 2160;
      refreshRate = 120;
      bitdepth = 10;
      inherit scale;
      workspaces = [
        6
        7
        8
        9
        10
      ];
      layout = "tile";
      position = "auto-right";
    }
  ];
in
{
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
    ./features/desktop/optional/jellyfin.nix

    # dev
    ./features/dev/jetbrains.nix
    ./features/dev/vscode.nix
    ./features/dev/mise.nix
    ./features/dev/java.nix
    ./features/dev/kubectl.nix

    ./features/dev/gh.nix
    ./features/dev/glab.nix

    ./features/dev/zed.nix
    ./features/dev/python.nix

    ./features/dev/codegraph.nix
    # ./features/dev/codex.nix

    ./features/dev/coding-agents.nix
    ./features/dev/cursor.nix
    ./features/dev/opencode.nix
    ./features/dev/opencommit.nix
    ./features/dev/omp.nix

    ./features/dev/herdr.nix

    ./features/dev/bruno.nix

    ./features/dev/t3code.nix
    ./features/dev/orca.nix
  ];

  monitorProfiles = {
    enable = true;
    default = "desktop-120";

    profiles = {
      desktop-120.monitors = dualDisplay 1.2;
      desktop.monitors = dualDisplay 1.0;
    };
  };
}
