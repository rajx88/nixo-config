{
  pkgs,
  config,
  ...
}: let
  wallpaper = "${config.xdg.dataHome}/wallpapers";
in {
  home.packages = with pkgs; [
    swaybg
  ];

  xdg.configFile."hypr" = {
    recursive = true;
    source = ./scripts;
    target = "hypr/scripts";
  };

  wayland.windowManager.hyprland.settings = {
    bind = let
      script = "${pkgs.python3}/bin/python3 ${config.xdg.configHome}/hypr/scripts/wall-changer.py";
    in [
      "$mod SHIFT,r,exec, ${script} ${wallpaper}"
    ];

    exec = [
      "${pkgs.swaybg}/bin/swaybg -i ${wallpaper}/wall-01.jpg --mode fill"
    ];
  };
}
