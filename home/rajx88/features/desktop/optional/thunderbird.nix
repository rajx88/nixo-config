{
  programs.thunderbird = {
    enable = true;
    profiles."rajx88" = {
      isDefault = true;
    };
  };

  home.persistence."/persist".directories = [".thunderbird"];
}
