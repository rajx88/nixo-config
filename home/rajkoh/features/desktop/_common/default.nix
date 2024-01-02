{pkgs, ...}: {
  imports = [
    ./alacritty
    ./discord
    ./firefox.nix
    ./fonts.nix
    ./gtk.nix
    ./playerctl.nix
    ./qt.nix
    ./spotify.nix
    ./vscode.nix
    ./wallpapers
    ./whatsapp.nix
  ];
  xdg.portal.enable = true;

  home.packages = with pkgs; [
    xdg-utils
  ];
}
