{
  pkgs,
  config,
  ...
}: {
  xdg.dataFile."wallpapers" = {
    source = ./wps;
    target = "wallpapers";
    recursive = true;
  };
}
