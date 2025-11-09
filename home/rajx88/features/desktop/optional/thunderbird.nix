{
  programs.thunderbird = {
    enable = true;
    profiles."rajx88" = {
      isDefault = true;
    };
  };

  home.persistence = {
    "/persist/home/rajx88".directories = [".thunderbird"];
  };
}
