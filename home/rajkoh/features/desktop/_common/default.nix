{pkgs, ...}: {
  imports = [
    ./1password.nix
    ./alacritty
    ./ghostty
    ./firefox.nix
    ./fonts.nix
    ./gtk.nix
    ./playerctl.nix
    ./qt.nix
    ./wallpapers
  ];
  xdg.portal.enable = true;

  home.packages = with pkgs; [
    xdg-utils
  ];
}
