{pkgs, ...}: {
  home.persistence."/persist".directories = [
    ".local/share/keyrings"
  ];

  home.packages = [pkgs.gcr];

  services.gnome-keyring = {
    enable = true;
    # components = [
    #   "secrets"
    #   "ssh"
    # ];
  };
}
