{
  pkgs,
  config,
  ...
}: let
  wallpaperDir = "${config.xdg.dataHome}/wallpapers";
in {
  home = {
    sessionVariables = {
      DEFAULT_WP = "${wallpaperDir}/wall-01.jpg";
    };
    packages = with pkgs; [
      swaybg
    ];
  };

  xdg.configFile."hypr" = {
    recursive = true;
    source = ./scripts;
    target = "hypr/scripts";
  };

  wayland.windowManager.hyprland.settings = {
    bind = let
      script = "${pkgs.python3}/bin/python3 ${config.xdg.configHome}/hypr/scripts/wall-changer.py";
    in [
      "$mod SHIFT,r,exec, ${script} -d ${wallpaperDir}"
    ];

    exec = [
      "${pkgs.swaybg}/bin/swaybg -i ${wallpaperDir}/wall-01.jpg -m fill"
    ];
  };
}
