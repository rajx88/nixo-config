{
  pkgs,
  inputs,
  config,
  lib,
  ...
}: let
  pacEnabled = config.services.proxy.pac.enable or false;
  pacUrl = config.services.proxy.pac.url or "";
in {
  programs.firefox = {
    enable = true;
    policies = lib.mkIf pacEnabled {
      NetworkManagement = {
        ProxySettings = {
          Mode = "autoConfig";
          AutoConfigURL = pacUrl;
        };
      };
    };
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
