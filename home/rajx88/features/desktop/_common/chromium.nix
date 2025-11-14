{
  pkgs,
  config,
  lib,
  ...
}: {
  programs.chromium = {
    enable = true;
    # package = pkgs.brave;
    extensions = [
      {id = "aeblfdkhhhdcdjpifhhbdiojplfjncoa";} # 1Password
    ];
    # Set PAC URL via command line if enabled
    commandLineArgs = lib.optionals (config.programs.proxy.pac.enable or false) [
      "--proxy-pac-url=${config.programs.proxy.pac.url}"
    ];
  };

  # xdg.mimeApps.defaultApplications = {
  #   "image/*" = ["chromium.desktop"];
  #   "text/html" = ["chromium.desktop"];
  #   "text/xml" = ["chromium.desktop"];
  #   "x-scheme-handler/http" = ["chromium.desktop"];
  #   "x-scheme-handler/https" = ["chromium.desktop"];
  # };

  home.persistence."/persist".directories = [".config/chromium"];
}
