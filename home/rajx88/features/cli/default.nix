{pkgs, ...}: {
  imports = [
    ./bash.nix
    ./bat.nix
    ./devbox.nix
    ./direnv.nix
    ./fish.nix
    ./git.nix
    ./gpg.nix
    ./just.nix
    ./nvim
    # ./pure.nix
    ./ssh.nix
    ./starship
    ./tmux.nix
    ./zoxide.nix
    # ./zellij.nix
    # ./sheldon.nix
    ./yazi.nix
    ./atuin.nix
    ./antidote.nix
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
    alejandra # Nix formatter

    ltex-ls # Spell checking LSP

    fastfetch # nix btw

    lazygit

    tokei

    killall
    dig
    dnslookup

    zip
    unzip

    tldr
  ];
}
