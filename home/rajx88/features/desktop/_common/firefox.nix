{
  pkgs,
  inputs,
  config,
  lib,
  osConfig,
  ...
}: let
  # Access NixOS config via osConfig when running as NixOS module
  pacEnabled = osConfig.services.proxy.pac.enable or false;
  pacUrl = osConfig.services.proxy.pac.url or "";
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
