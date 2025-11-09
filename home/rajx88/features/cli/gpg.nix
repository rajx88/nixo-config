{pkgs, ...}: {
  home.packages = with pkgs; [
    pinentry-curses
  ];
  programs.gpg = {
    enable = true;
  };
}
