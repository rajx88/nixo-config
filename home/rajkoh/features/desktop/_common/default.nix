{
  imports = [
    ./alacritty
    ./discord.nix
    ./firefox.nix
    ./fonts.nix
    ./gtk.nix
    # ./obsidian.nix
    ./qt.nix
    ./spotify.nix
    ./vscode.nix
    ./wezterm
    ./whatsapp.nix
  ];
  xdg.portal.enable = true;
}
