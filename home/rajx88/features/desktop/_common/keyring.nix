{pkgs, ...}: {
  home.persistence."/persist".directories = [
    ".local/share/keyrings"
  ];

  home.packages = [pkgs.gcr_4];

  services.gnome-keyring = {
    enable = true;
    # components = [
    #   "secrets"
    #   "ssh"
    # ];
  };
}
