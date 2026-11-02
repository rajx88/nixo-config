{
  pkgs,
  inputs,
  ...
}:
let
  uaSwitcher = (import ./ua-switcher-policies.nix { }).uaSwitcherManagedPolicy;
in
{
  programs.firefox = {
    enable = true;
    profiles.rajx88.bookmarks = { };
    policies = uaSwitcher;
  };

  # xdg.mimeApps.defaultApplications = {
  #   "image/*" = ["firefox.desktop"];
  #   "text/html" = ["firefox.desktop"];
  #   "text/xml" = ["firefox.desktop"];
  #   "x-scheme-handler/http" = ["firefox.desktop"];
  #   "x-scheme-handler/https" = ["firefox.desktop"];
  # };

  home.persistence."/persist".directories = [ ".mozilla/firefox" ];
}
