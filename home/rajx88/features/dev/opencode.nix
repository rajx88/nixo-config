{
  config,
  pkgs,
  ...
}: {
  programs.opencode = {
    enable = true;
  };

  home.persistence."/persist".directories = [
    ".local/share/opencode"
    ".config/opencode"
  ];
}
