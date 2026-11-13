{ pkgs, lib, ... }:
let
  mkZshCompletion = import ../../lib/zsh-completion.nix { inherit pkgs lib; };
in
{
  imports = [
    ./bash.nix
    ./bat.nix
    ./devbox.nix
    ./direnv.nix
    ./git.nix
    ./gpg.nix
    ./just.nix
    ./nvim
    # ./pure.nix
    ./prmt.nix
    ./ssh.nix
    # ./starship
    ./tmux.nix
    ./zoxide.nix

    ./yazi.nix
    ./superfile.nix
    ./atuin.nix
    ./antidote.nix
    ./zsh.nix
  ];

  home.packages =
    (with pkgs; [
      bottom # System viewer
      broot # file viewer
      eza # Better ls
      ripgrep # Better grep
      fd # Better find
      fzf # fuzzy finder
      httpie # Better curl
      # diffsitter # Better diff
      jq # JSON pretty printer and manipulator

      nil # Nix LSP
      nixfmt # Nix formatter

      ltex-ls-plus # Spell checking LSP (ltex-ls was archived upstream)

      fastfetch # nix btw

      lazygit

      tokei

      killall
      dig
      dnslookup

      zip
      unzip

      tldr

      nodejs

      # Stock fish, available on demand (no managed config — launches with defaults)
      fish
    ])
    ++ [
      # Generated at build time instead of spawning lazygit on every shell init.
      (mkZshCompletion "lazygit" pkgs.lazygit "lazygit" "completion zsh")
    ];
}
