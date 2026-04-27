{ ... }: {
  services.displayManager.ly.enable = true;

  security.pam.services.ly.enableGnomeKeyring = true;

  environment.persistence."/persist".files = [
    "/etc/ly/save"
  ];
}
