{
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
    settings = {
      sync_address = "http://atuin.lan";
      auto_sync = true;
      sync_frequency = "5m";
    };
  };

  home.persistence."/persist".directories = [
    ".local/share/atuin"
    ".config/atuin"
  ];
}
