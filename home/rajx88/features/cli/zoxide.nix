{
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
  };

  home.persistence."/persist".directories = [".local/share/zoxide"];
}
