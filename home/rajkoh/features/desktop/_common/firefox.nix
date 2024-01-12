{
  pkgs,
  inputs,
  ...
}: {
  programs.firefox = {
    enable = true;
    profiles.rajkoh = {
      bookmarks = {};
      extensions = with pkgs.inputs.firefox-addons; [
        ublock-origin
      ];
    };
  };

  xdg.mimeApps.defaultApplications = {
    "image/*" = ["firefox.desktop"];
    "text/html" = ["firefox.desktop"];
    "text/xml" = ["firefox.desktop"];
    "x-scheme-handler/http" = ["firefox.desktop"];
    "x-scheme-handler/https" = ["firefox.desktop"];
  };

  home.persistence = {
    # "/persist/home/rajkoh".directories = [".mozilla/firefox"];
  };
}
