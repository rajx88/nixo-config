{
  home.persistence = {
    "/persist/home/rajkoh".directories = [
      ".local/share/direnv"
    ];
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;

    enableZshIntegration = true;
    enableBashIntegration = true;

    config = builtins.fromTOML ''
      [global]
      load_dotenv = true
    '';
  };
}
