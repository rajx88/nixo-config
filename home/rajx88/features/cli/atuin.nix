{
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
    settings = {
      # atuin.home.arpa, not atuin.lan: `.lan` is served by Pi-hole but is
      # NOT routed in Tailscale's split DNS, so it would not resolve away from
      # home. `home.arpa` is the split-DNS domain, so this address works both on
      # the LAN and over the tailnet. Port 8888 is atuin-server itself — there
      # is no reverse proxy in front of it, so the port is part of the URL.
      sync_address = "http://atuin.home.arpa:8888";
      auto_sync = true;
      sync_frequency = "5m";

      threads = {
        capture = true;
        capture_tools = true;
      };

      daemon = {
        enabled = true;
        autostart = true;
      };
    };
  };

  home.persistence."/persist".directories = [
    ".local/share/atuin"
    ".config/atuin"
  ];
}
