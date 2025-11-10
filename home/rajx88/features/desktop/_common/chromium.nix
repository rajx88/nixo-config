{
  pkgs,
  config,
  lib,
  ...
}: {
  programs.chromium = {
    enable = true;
    package = pkgs.brave;
    extensions = [
      {id = "aeblfdkhhhdcdjpifhhbdiojplfjncoa";} # 1Password
    ];
    # Set PAC URL via command line if enabled
    commandLineArgs = lib.optionals (config.programs.proxy.pac.enable or false) [
      "--proxy-pac-url=${config.programs.proxy.pac.url}"
    ];
  };

  # xdg.mimeApps.defaultApplications = {
  #   "image/*" = ["brave.desktop"];
  #   "text/html" = ["brave.desktop"];
  #   "text/xml" = ["brave.desktop"];
  #   "x-scheme-handler/http" = ["brave.desktop"];
  #   "x-scheme-handler/https" = ["brave.desktop"];
  # };

  home.persistence = {
    "/persist/home/rajx88".directories = [".config/BraveSoftware/Brave-Browser"];
  };
}
