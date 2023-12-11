{

  xdg = {
    configFile."tmux" = {
      source = ./config;
      recursive = true;
    };
  };

  programs.tmux = {
    enable = true;
    clock24 = false;
  };
}