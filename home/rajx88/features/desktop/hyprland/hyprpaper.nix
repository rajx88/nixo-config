{
  pkgs,
  config,
  ...
}: let
  wallpaperDir = "${config.xdg.dataHome}/wallpapers";
in {
  xdg.configFile."hypr/hyprpaper.conf".text = ''
    # set the default wallpaper(s) seen on inital workspace(s) --depending on the number of monitors used
    wallpaper {
     monitor =
     path = ${wallpaperDir}/wall-01.jpg
    }

  '';

  xdg.configFile."hypr" = {
    recursive = true;
    source = ./scripts;
    target = "hypr/scripts";
  };

  home = {
    sessionVariables = {
      DEFAULT_WP = "${wallpaperDir}/wall-01.jpg";
    };
    packages = with pkgs; [
      hyprpaper
    ];
  };

  wayland.windowManager.hyprland.settings = {
    bind = let
      script = "${config.xdg.configHome}/hypr/scripts/hypr-paper-changer.sh";
    in [
      "$mod SHIFT,r,exec, ${script}"
    ];
    exec-once = [
      "${pkgs.hyprpaper}/bin/hyprpaper"
    ];
  };
}
