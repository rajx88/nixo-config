{
  inputs,
  outputs,
  ...
}: {
  imports = [
    ./global

    # ./features/desktop/gnome
    ./features/desktop/hyprland
  ];

  #  ------   -----   ------
  # | DP-3 | | DP-1| | DP-2 |
  #  ------   -----   ------
  monitors = [
    {
      name = "HDMI-3";
      width = 2560;
      height = 1440;
      x = 0;
      workspace = "3";
    }
    {
      name = "DP-1";
      width = 2560;
      height = 1440;
      x = 2560;
      workspace = "1";
      primary = true;
    }
    {
      name = "DP-2";
      width = 2560;
      height = 1440;
      x = 5120;
      workspace = "2";
    }
  ];
}
