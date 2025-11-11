{
  pkgs,
  inputs,
  config,
  lib,
  ...
}: let
  # Access home-manager proxy config
  pacEnabled = config.programs.proxy.pac.enable or false;
  pacUrl = config.programs.proxy.pac.url or "";
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

      # Set PAC file via user.js settings
      settings = lib.mkIf pacEnabled {
        "network.proxy.type" = 2; # 2 = PAC (auto proxy config)
        "network.proxy.autoconfig_url" = pacUrl;
        "network.proxy.share_proxy_settings" = true;
      };
    };
  };

  # xdg.mimeApps.defaultApplications = {
  #   "image/*" = ["firefox.desktop"];
  #   "text/html" = ["firefox.desktop"];
  #   "text/xml" = ["firefox.desktop"];
  #   "x-scheme-handler/http" = ["firefox.desktop"];
  #   "x-scheme-handler/https" = ["firefox.desktop"];
  # };

  home.persistence."/persist".directories = [".mozilla/firefox"];
}
