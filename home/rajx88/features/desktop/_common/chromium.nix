{
  pkgs,
  ...
}:
{
  programs.chromium = {
    enable = true;
    extensions = [
      { id = "aeblfdkhhhdcdjpifhhbdiojplfjncoa"; } # 1Password
    ];
  };

  # xdg.mimeApps.defaultApplications = {
  #   "image/*" = ["chromium.desktop"];
  #   "text/html" = ["chromium.desktop"];
  #   "text/xml" = ["chromium.desktop"];
  #   "x-scheme-handler/http" = ["chromium.desktop"];
  #   "x-scheme-handler/https" = ["chromium.desktop"];
  # };

  home.persistence."/persist".directories = [ ".config/chromium" ];
}
