{ ... }: {
  services.displayManager.ly.enable = true;

  # ly hardcodes its own PAM rules (useDefaultRules = false) that substack/include
  # the "login" service for auth/session instead of using the auto-generated rule
  # list, so `security.pam.services.ly.enableGnomeKeyring` is silently a no-op.
  # Wire it on "login" instead, same trick LightDM/GDM rely on (nixpkgs#246197).
  security.pam.services.login.enableGnomeKeyring = true;

  environment.persistence."/persist".files = [
    "/etc/ly/save.txt"
  ];
}
