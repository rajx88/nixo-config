{ pkgs, ... }:
{
  imports = [
    ./1password.nix
    ./alacritty.nix
    ./discord.nix
    ./firefox.nix
    ./gtk.nix
    ./qt.nix
    ./wezterm.nix
  ];
  
}
