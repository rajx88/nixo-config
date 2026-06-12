{pkgs, ...}: {
  programs.qutebrowser = {
    enable = true;
  };

  home.persistence."/persist".directories = [
    ".local/share/qutebrowser"
    ".config/qutebrowser"
  ];
}
