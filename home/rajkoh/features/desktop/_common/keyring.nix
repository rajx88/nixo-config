{pkgs, ...}: {
  home.persistence = {
    "/persist/home/rajkoh".directories = [
      ".local/share/keyrings"
    ];
  };

  home.packages = [pkgs.gcr];

  services.gnome-keyring = {
    enable = true;
    # components = [
    #   "secrets"
    #   "ssh"
    # ];
  };
}
