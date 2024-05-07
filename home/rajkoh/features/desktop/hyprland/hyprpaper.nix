{
  pkgs,
  config,
  ...
}: let
  wallpaperDir = "${config.xdg.dataHome}/wallpapers";
in {
  xdg.configFile."hypr/hyprpaper.conf".text = ''
    preload = ${wallpaperDir}/bg-1.jpg
    preload = ${wallpaperDir}/bg-2.jpg
    preload = ${wallpaperDir}/bg-3.jpg
    preload = ${wallpaperDir}/bg-4.jpg
    preload = ${wallpaperDir}/bg-5.jpg
    preload = ${wallpaperDir}/bg-6.jpg
    preload = ${wallpaperDir}/bg-7.jpg
    preload = ${wallpaperDir}/bg-8.jpg
    preload = ${wallpaperDir}/bg-9.jpg
    preload = ${wallpaperDir}/bg-10.jpg
    preload = ${wallpaperDir}/bg-11.jpg
    preload = ${wallpaperDir}/bg-12.jpg
    preload = ${wallpaperDir}/bg-13.jpg
    preload = ${wallpaperDir}/bg-14.jpg
    preload = ${wallpaperDir}/bg-15.jpg
    preload = ${wallpaperDir}/bg-16.png
    # preload = ${wallpaperDir}/bg-17.png

    # set the default wallpaper(s) seen on inital workspace(s) --depending on the number of monitors used
    wallpaper = ,${wallpaperDir}/bg-1.jpg

  '';

  home = {
    sessionVariables = {
      DEFAULT_WP = "${wallpaperDir}/wall-01.jpg";
    };
    packages = with pkgs; [
      hyprpaper
    ];
  };

  wayland.windowManager.hyprland.settings = {
    exec = [
      "${pkgs.hyprpaper}/bin/hyprpaper"
    ];
  };
}
