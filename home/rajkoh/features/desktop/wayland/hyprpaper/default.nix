{
  pkgs,
  config,
  ...
}: {
  xdg.configFile."hyprpaper" = {
    source = ./wp;
    target = "hyprpaper/wp";
    recursive = true;
  };

  home.packages = with pkgs; [
    hyprpaper
  ];
}
