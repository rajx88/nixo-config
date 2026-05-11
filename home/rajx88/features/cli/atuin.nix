{
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      sync_address = "http://10.0.0.1:8888";
      auto_sync = true;
      sync_frequency = "5m";
    };
  };

  home.persistence."/persist".directories = [
    ".local/share/atuin"
    ".config/atuin"
  ];
}
