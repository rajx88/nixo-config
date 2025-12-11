{
  pkgs,
  config,
  lib,
  ...
}: let
  pacEnabled = config.programs.proxy.pac.enable or false;
  pacUrl = config.programs.proxy.pac.url or "";
  braveExec =
    if pacEnabled
    then "${pkgs.brave}/bin/brave --proxy-pac-url=${pacUrl} %U"
    else "${pkgs.brave}/bin/brave %U";
in {
  home.packages = [
    (pkgs.brave.overrideAttrs (old: {
      postInstall =
        (old.postInstall or "")
        + ''
          for entry in $out/share/applications/brave*.desktop; do
            if [ -f "$entry" ]; then
              sed -i "s|^Exec=.*|Exec=${braveExec}|" "$entry"
            fi
          done
        '';
    }))
  ];

  # xdg.mimeApps.defaultApplications = {
  #   "image/*" = ["brave.desktop"];
  #   "text/html" = ["brave.desktop"];
  #   "text/xml" = ["brave.desktop"];
  #   "x-scheme-handler/http" = ["brave.desktop"];
  #   "x-scheme-handler/https" = ["brave.desktop"];
  # };

  home.persistence."/persist".directories = [".config/BraveSoftware/Brave-Browser"];
}
