{pkgs, ...}: {
  home.persistence = {
    "/persist/home/rajx88".directories = [
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
