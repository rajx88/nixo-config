{
  imports = [
    ./alacritty
    ./discord.nix
    ./firefox.nix
    ./fonts.nix
    ./gtk.nix
    ./playerctl.nix
    ./qt.nix
    ./spotify.nix
    ./vscode.nix
    ./whatsapp.nix
  ];
  xdg.portal.enable = true;
}
