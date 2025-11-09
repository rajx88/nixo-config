{
  pkgs,
  config,
  lib,
  ...
}: {
  home = {
    sessionVariables = {
      DEFAULT_WP = "${wallpaperDir}/wall-01.jpg";
    };
    packages = with pkgs; [
      waypaper
      swaybg
    ];
  };

  xdg.configFile."waypaper/config.ini" = {
    text =
      /*
      ini
      */
      ''
        [Settings]
        folder = ${config.xdg.dataHome}/wallpapers
        fill = fill
        sort = name
        backend = swaybg
        color = #ffffff
        subfolders = False
        wallpaper = None
        monitors = All
      '';
  };

  wayland.windowManager.hyprland.settings = {
    exec = [
      "${pkgs.waypaper}/bin/waypaper --random"
    ];
  };
}
