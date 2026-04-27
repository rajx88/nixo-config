{
  config,
  lib,
  pkgs,
  ...
}: {
  options.services.greetd.sessionCommand = lib.mkOption {
    type = lib.types.str;
    default = "start-hyprland";
    description = "Session command passed to tuigreet --cmd";
  };

  config = {
    services.greetd = {
      enable = true;
      settings.default_session = {
        user = "greeter";
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd ${config.services.greetd.sessionCommand}";
      };
    };

    security.pam.services.greetd.enableGnomeKeyring = true;

    environment.persistence."/persist".directories = [
      "/var/cache/tuigreet"
    ];
  };
}
