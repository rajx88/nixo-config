{
  pkgs,
  inputs,
  ...
}: {
  programs.firefox = {
    enable = true;
    profiles.rajkoh = {
      bookmarks = {};
    };
  };

  xdg.mimeApps.defaultApplications = {
    "image/*" = ["firefox.desktop"];
    "text/html" = ["firefox.desktop"];
    "text/xml" = ["firefox.desktop"];
    "x-scheme-handler/http" = ["firefox.desktop"];
    "x-scheme-handler/https" = ["firefox.desktop"];
  };
}
