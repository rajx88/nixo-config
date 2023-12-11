{ pkgs, ... }: 
{
  imports = [
    ./bash.nix
    ./bat.nix
    ./direnv.nix
    ./fish.nix
    ./git.nix
    ./ssh.nix
    ./starship
    ./tmux
    ./zsh
  ];
  home.packages = with pkgs; [
    bottom # System viewer
    broot
    eza # Better ls
    ripgrep # Better grep
    fd # Better find
    httpie # Better curl
    diffsitter # Better diff
    jq # JSON pretty printer and manipulator

    nil # Nix LSP
    nixfmt # Nix formatter

    ltex-ls # Spell checking LSP

    gnumake

    neofetch
  ];
}
