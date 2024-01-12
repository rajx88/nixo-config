{pkgs, ...}: {
  imports = [
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

  services.gnome-keyring.enable = true;

  home.packages = with pkgs; [
    xdg-utils
  ];
}
