{pkgs, ...}: {
  imports = [
    ./1password.nix
    ./alacritty
    ./firefox.nix
    ./fonts.nix
    ./gtk.nix
    ./playerctl.nix
    ./qt.nix
    ./wallpapers
    ./wezterm
  ];
  xdg.portal.enable = true;

  home.packages = with pkgs; [
    xdg-utils
  ];
}
