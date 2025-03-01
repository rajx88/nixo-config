{pkgs, ...}: {
  home.packages = [pkgs.gcr];

  services.gnome-keyring = {
    enable = true;
    # components = [
    #   "secrets"
    #   "ssh"
    # ];
  };
}
