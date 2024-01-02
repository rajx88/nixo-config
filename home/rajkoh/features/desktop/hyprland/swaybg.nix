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

  wayland.windowManager.hyprland.settings = {
    exec = [
      "${pkgs.swaybg}/bin/swaybg -i ${wallpaper}/wall-01.jpg --mode fill"
    ];
  };
}
