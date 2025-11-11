{
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
  };

  home.persistence."/persist".directories = [
    ".local/share/atuin"
    ".config/atuin"
  ];
}
