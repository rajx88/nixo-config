{pkgs, config, ...}:
{

  home.sessionVariables.STARSHIP_CONFIG = "${config.xdg.configHome}/starship/starship.toml";

  xdg = {
    configFile."starship" = {
      source = ./config;
      recursive = true;
    };
  };

  programs.starship = {
    enable = true;
  };
}
