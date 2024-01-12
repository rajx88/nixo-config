{
  pkgs,
  config,
  ...
}: {
  programs.password-store = {
    enable = true;
    settings = {
      PASSWORD_STORE_DIR = "$HOME/.password-store";
    };
  };

  services.pass-secret-service = {
    enable = true;
  };

  home.persistence = {
    "/persist/home/rajkoh".directories = [".password-store"];
  };
}
