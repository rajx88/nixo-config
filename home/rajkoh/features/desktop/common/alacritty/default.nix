{

  xdg = {
    configFile."alacritty" = {
      source = ./config;
      recursive = true;
    };
  };

  programs.alacritty = {
    enable = true;
  };
}
