{
  pkgs,
  lib,
  config,
  ...
}: {
  # Declarative Microsoft Teams PWA setup using Brave (or Chromium/Edge).
  # Reasoning:
  #  - Official Linux client deprecated; Electron wrapper adds overhead.
  #  - PWA auto-updates with Microsoft's web deployment and shares Chromium engine.
  #  - We isolate into a dedicated profile directory for persistence + crash recovery.

  # Brave is already installed via programs.chromium in chromium.nix

  # Persist the profile if you use impermanence (uncomment & adjust path/root as needed):
  home.persistence."/persist/home/rajx88".directories = [
    ".local/share/teams-web-profile"
  ];

  # Desktop entry to launch Teams as an app-like window (SSB) with Wayland + PipeWire flags.
  xdg.desktopEntries.teams-web = let
    profileDir = "${config.home.homeDirectory}/.local/share/teams-web-profile";
  in {
    name = "Microsoft Teams (Web)";
    genericName = "Teams";
    comment = "Microsoft Teams Progressive Web App via Brave";
    # Desktop Entry spec recommends one main category; keep Network + add Chat via keywords if needed.
    categories = ["Network" "InstantMessaging"];
    # Use %h for home dir inside Exec; no unescaped $.
    exec = "${pkgs.brave}/bin/brave --class=TeamsWeb --name=TeamsWeb --app=https://teams.microsoft.com --user-data-dir=${profileDir} --enable-features=UseOzonePlatform,WebRTCPipeWireCapturer --ozone-platform=wayland";
    icon = "teams"; # Provide an icon (can symlink/copy). Fallback: brave icon if not found.
    terminal = false;
    startupNotify = true;
  };

  # External extension manifest for Brave inside the isolated PWA profile so 1Password auto-installs.
  # Brave/Chromium will fetch the extension from the Web Store using external_update_url.
  home.file.".local/share/teams-web-profile/External Extensions/aeblfdkhhhdcdjpifhhbdiojplfjncoa.json" = {
    text = builtins.toJSON {
      external_update_url = "https://clients2.google.com/service/update2/crx";
    };
    # Ensure directory chain exists and correct perms.
    recursive = true;
  };

  # Additional extension auto-install manifest.
  home.file.".local/share/teams-web-profile/External Extensions/bhchdcejhohfmigjafbampogmaanbfkg.json" = {
    text = builtins.toJSON {
      external_update_url = "https://clients2.google.com/service/update2/crx";
    };
    recursive = true;
  };
}
