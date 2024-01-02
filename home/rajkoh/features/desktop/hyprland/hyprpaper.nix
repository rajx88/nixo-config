{
  pkgs,
  config,
  ...
}: let
  wallpaper = "${config.xdg.dataHome}/wallpapers";
in {
  xdg.configFile."hypr/hyprpaper.conf".text = ''
    preload = ${wallpaper}/bg-1.jpg
    preload = ${wallpaper}/bg-2.jpg
    preload = ${wallpaper}/bg-3.jpg
    preload = ${wallpaper}/bg-4.jpg
    preload = ${wallpaper}/bg-5.jpg
    preload = ${wallpaper}/bg-6.jpg
    preload = ${wallpaper}/bg-7.jpg
    preload = ${wallpaper}/bg-8.jpg
    preload = ${wallpaper}/bg-9.jpg
    preload = ${wallpaper}/bg-10.jpg
    preload = ${wallpaper}/bg-11.jpg
    preload = ${wallpaper}/bg-12.jpg
    preload = ${wallpaper}/bg-13.jpg
    preload = ${wallpaper}/bg-14.jpg
    preload = ${wallpaper}/bg-15.jpg
    preload = ${wallpaper}/bg-16.png
    # preload = ${wallpaper}/bg-17.png

    # set the default wallpaper(s) seen on inital workspace(s) --depending on the number of monitors used
    wallpaper = ,${wallpaper}/bg-1.jpg

  '';

  home.packages = with pkgs; [
    hyprpaper
  ];

  wayland.windowManager.hyprland.settings = {
    exec = [
      "${pkgs.hyprpaper}/bin/hyprpaper"
    ];
  };
}
