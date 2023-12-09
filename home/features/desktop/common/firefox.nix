{ pkgs, ... }:

{
  programs.firefox = {
    enable = true;
    profiles.rajkoh= {
      bookmarks = { };
      extensions = with pkgs.inputs.firefox-addons; [
        ublock-origin
        1password 
      ];
    };
  };

  xdg.mimeApps.defaultApplications = {
    "text/html" = [ "firefox.desktop" ];
    "text/xml" = [ "firefox.desktop" ];
    "x-scheme-handler/http" = [ "firefox.desktop" ];
    "x-scheme-handler/https" = [ "firefox.desktop" ];
  };
}
