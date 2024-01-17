{
  programs.thunderbird = {
    enable = true;
    profiles."rajkoh" = {
      isDefault = true;
    };
  };

  home.persistence = {
    "/persist/home/rajkoh".directories = [".thunderbird"];
  };
}
