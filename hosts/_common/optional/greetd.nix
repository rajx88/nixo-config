{
  config,
  lib,
  pkgs,
  ...
}: let
  homeCfgs = config.home-manager.users;
  homeSharePaths = lib.mapAttrsToList (_: v: "${v.home.path}/share") homeCfgs;
  vars = ''XDG_DATA_DIRS="$XDG_DATA_DIRS:${lib.concatStringsSep ":" homeSharePaths}" GTK_USE_PORTAL=0'';

  conf = homeCfgs.rajkoh;

  sway-kiosk = command: "${lib.getExe pkgs.sway} --unsupported-gpu --config ${pkgs.writeText "kiosk.config" ''
    output * bg ${wallpaperDir}/wall-01.jpg fill
    xwayland disable
    input "type:touchpad" {
      tap enabled
    }
    exec '${vars} ${command}; ${pkgs.sway}/bin/swaymsg exit'
  ''}";

  hyprctl = "${conf.wayland.windowManager.hyprland.package}/bin/hyprctl";

  hyprland-kiosk = command: ''
    ${lib.getExe pkgs.hyprland} --config ${pkgs.writeText "hyprland.conf" ''
      exec-once = ${command}; ${hyprctl} dispatch exit
      misc {
          disable_hyprland_logo = true
          disable_splash_rendering = true
          disable_hyprland_qtutils_check = true
      }
    ''}
  '';

  wallpaperDir = "${conf.xdg.dataHome}/wallpapers";
in {
  # services.greetd = {
  #   enable = true;
  #   settings.default_session.command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --cmd Hyprland";
  # };

  security.pam.services.greetd.enableGnomeKeyring = true;

  environment.persistence = {
    "/persist".directories = [
      "/var/cache/tuigreet"
    ];
  };

  # environment.etc."greetd/environments".text = ''
  #   Hyprland
  # '';

  services.greetd = {
    enable = true;
    settings.default_session.command = sway-kiosk (lib.getExe config.programs.regreet.package);
  };

  programs.regreet = {
    enable = true;
    iconTheme = conf.gtk.iconTheme;
    theme = conf.gtk.theme;
    font = conf.fontProfiles.regular;
    # cursorTheme = {
    #   inherit (conf.gtk.cursorTheme) name package;
    # };

    settings.background = {
      path = "${wallpaperDir}/wall-01.jpg";
      fit = "Fill";
    };
  };
}
