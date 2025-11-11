{
  config,
  lib,
  pkgs,
  ...
}: {
  # greetd with tuigreet
  services.greetd = {
    enable = true;
    settings.default_session = {
      user = "greeter";
      command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd Hyprland";
    };
  };

  security.pam.services.greetd.enableGnomeKeyring = true;

  environment.persistence."/persist".directories = [
    "/var/cache/tuigreet"
  ];
}
