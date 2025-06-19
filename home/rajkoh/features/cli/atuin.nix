{
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
  };

  home.persistence = {
    "/persist/home/rajkoh".directories = [".local/share/atuin"];
  };
}
