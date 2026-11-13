{
  pkgs,
  lib,
  ...
}:
let
  mkZshCompletion = import ../../lib/zsh-completion.nix { inherit pkgs lib; };
in
{
  home.packages = [
    pkgs.herdr
    # Generated at build time instead of spawning herdr on every shell init.
    (mkZshCompletion "herdr" pkgs.herdr "herdr" "completion zsh")
  ];

  # ~/.config/herdr holds config.toml (including the first-run `onboarding = false`
  # marker) and session.json; ~/.local/state/herdr holds the agent-detection and
  # client-shell state. Off the ephemeral root they are wiped every boot, which
  # makes herdr replay the first-run overlay and forget saved workspaces.
  home.persistence."/persist".directories = [
    ".config/herdr"
    ".local/state/herdr"
  ];
}
