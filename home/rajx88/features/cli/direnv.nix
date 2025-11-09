{
  home.persistence = {
    "/persist/home/rajx88".directories = [
      ".local/share/direnv"
    ];
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    mise.enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;

    config = builtins.fromTOML ''
      [global]
      load_dotenv = true
    '';
  };
}
