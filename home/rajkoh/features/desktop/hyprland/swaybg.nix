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
      "$mod SHIFT,r,exec, ${script} -d ${wallpaper}"
    ];

    exec = let
      randomWallpaper = "${pkgs.python3}/bin/python3 ${config.xdg.configHome}/hypr/scripts/wall-changer.py -m random ${wallpaper}";
    in [
      "${pkgs.swaybg}/bin/swaybg -i ${randomWallpaper} -m fill"
    ];
  };
}
