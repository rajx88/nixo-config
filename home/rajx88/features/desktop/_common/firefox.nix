{
  pkgs,
  inputs,
  ...
}: {
  programs.firefox = {
    enable = true;
    profiles.rajx88 = {
      bookmarks = {};
    };
  };

  # xdg.mimeApps.defaultApplications = {
  #   "image/*" = ["firefox.desktop"];
  #   "text/html" = ["firefox.desktop"];
  #   "text/xml" = ["firefox.desktop"];
  #   "x-scheme-handler/http" = ["firefox.desktop"];
  #   "x-scheme-handler/https" = ["firefox.desktop"];
  # };

  home.persistence = {
    "/persist/home/rajx88".directories = [".mozilla/firefox"];
  };
}
