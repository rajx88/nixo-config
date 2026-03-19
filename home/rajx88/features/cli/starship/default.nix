{
  pkgs,
  config,
  lib,
  ...
}: {
  # xdg.configFile."starship" = {
  #   source = ./config;
  #   recursive = true;
  # };

  # home.sessionVariables.STARSHIP_CONFIG = "${config.xdg.configHome}/starship/starship.toml";

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
    settings = {
      git_status = {
        ignore_submodules = true;
        windows_starship = "";
      };
      git_branch = {
        ignore_bare_repo = true;
        format = "on [$symbol$branch(:$remote_branch)]($style) ";
      };
      directory = {
        truncate_to_repo = false;
      };
    };
  };
}
