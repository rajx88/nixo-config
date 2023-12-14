{ pkgs, ... }: 
{
  imports = [
    ./bash.nix
    ./bat.nix
    ./direnv.nix
    ./fish.nix
    ./git.nix
    ./nvim
    ./ssh.nix
    ./starship
    ./tmux.nix
    ./zsh.nix
  ];

  home.packages = with pkgs; [
    bottom # System viewer
    broot # file viewer 
    eza # Better ls
    ripgrep # Better grep
    fd # Better find
    fzf # fuzzy finder
    httpie # Better curl
    diffsitter # Better diff
    jq # JSON pretty printer and manipulator

    nil # Nix LSP
    nixfmt # Nix formatter

    ltex-ls # Spell checking LSP

    gnumake # make Makefile
    gcc

    neofetch # nix btw

    neo-cowsay # mooooooooo
    fortune-kind # fortune
    zoxide # A fast cd command that learns your habits

    lazygit
  ];
}
