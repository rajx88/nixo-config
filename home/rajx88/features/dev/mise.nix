{...}: {
  home.persistence."/persist".directories = [
    ".local/share/mise"
    ".local/state/mise"
  ];
  programs.mise = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
  };
}
