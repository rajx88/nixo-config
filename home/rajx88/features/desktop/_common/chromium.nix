{pkgs, ...}: {
  programs.chromium = {
    enable = true;
    package = pkgs.brave;
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
