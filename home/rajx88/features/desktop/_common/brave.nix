{
  pkgs,
  config,
  lib,
  ...
}: let
  pacEnabled = config.programs.proxy.pac.enable or false;
  pacUrl = config.programs.proxy.pac.url or "";
  braveWrapped =
    if pacEnabled
    then
      pkgs.symlinkJoin {
        name = "brave-with-pac";
        paths = [pkgs.brave];
        buildInputs = [pkgs.makeWrapper];
        postBuild = ''
          wrapProgram $out/bin/brave \
            --add-flags "--proxy-pac-url=${pacUrl}"
        '';
      }
    else pkgs.brave;
in {
  home.packages = [braveWrapped];

  # xdg.mimeApps.defaultApplications = {
  #   "image/*" = ["brave.desktop"];
  #   "text/html" = ["brave.desktop"];
  #   "text/xml" = ["brave.desktop"];
  #   "x-scheme-handler/http" = ["brave.desktop"];
  #   "x-scheme-handler/https" = ["brave.desktop"];
  # };

  home.persistence."/persist".directories = [".config/BraveSoftware/Brave-Browser"];
}
