{ pkgs, ... }:
{
  imports = [
    ./1password.nix
    ./alacritty
    ./discord.nix
    ./firefox.nix
    # ./gtk.nix
    # ./qt.nix
    ./vscode.nix
    ./wezterm
  ];
  
}
