{
  pkgs,
  lib,
  config,
  ...
}: {
  # Declarative Microsoft Teams PWA setup using Brave.
  # Uses your main Brave profile so links open in your main browser naturally.
  # Desktop entry to launch Teams as an app-like window using main Brave profile.
  xdg.desktopEntries.teams-web = {
    name = "Microsoft Teams (Web)";
    genericName = "Teams";
    comment = "Microsoft Teams Progressive Web App via Brave";
    categories = ["Network" "InstantMessaging"];
    # No separate user-data-dir, uses your default Brave profile
    exec = "${pkgs.brave}/bin/brave --class=TeamsWeb --name=TeamsWeb --app=https://teams.microsoft.com --enable-features=UseOzonePlatform,WebRTCPipeWireCapturer --ozone-platform=wayland";
    icon = "teams";
    terminal = false;
    startupNotify = true;
  };
}
