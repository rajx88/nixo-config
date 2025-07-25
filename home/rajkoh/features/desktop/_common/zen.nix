{
  inputs,
  pkgs,
  config,
  ...
}: {
  # home.nix
  imports = [
    inputs.zen-browser.homeModules.beta
    # or inputs.zen-browser.homeModules.twilight
    # or inputs.zen-browser.homeModules.twilight-official
  ];

  home.persistence = {
    "/persist/home/rajkoh".directories = [".zen"];
  };

  programs.zen-browser = {
    enable = true;
    nativeMessagingHosts = [pkgs.firefoxpwa];
  };

  xdg.desktopEntries.zen = {
    name = "Zen Browser";
    genericName = "Web Browser";
    exec = "zen %u";
    icon = "web-browser";
    type = "Application";
    terminal = false;
    categories = ["Network" "WebBrowser"];
    mimeType = [
      "text/html"
      "x-scheme-handler/http"
      "x-scheme-handler/https"
    ];
  };
}
