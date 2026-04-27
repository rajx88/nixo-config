{
  pkgs,
  config,
  ...
}: {
  home.sessionVariables.LOCKSCREEN_WP = "${config.home.homeDirectory}/.local/share/wallpapers/wall-02.jpg";

  xdg.dataFile."wallpapers" = {
    source = ./wps;
    target = "wallpapers";
    recursive = true;
  };
}
