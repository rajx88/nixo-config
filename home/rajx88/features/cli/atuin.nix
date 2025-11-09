{
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
  };

  home.persistence = {
    "/persist/home/rajx88".directories = [
      ".local/share/atuin"
      ".config/atuin"
    ];
  };
}
