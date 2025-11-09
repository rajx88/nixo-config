{pkgs, ...}: {
  imports = [
    ./1password.nix
    ./alacritty
    ./ghostty.nix
    ./firefox.nix
    ./chromium.nix
    ./fonts.nix
    ./gtk.nix
    ./playerctl.nix
    ./qt.nix
    ./wallpapers
    ./keyring.nix
    ./zen.nix
  ];
  xdg.portal.enable = true;

  home.packages = with pkgs; [
    xdg-utils
  ];
}
