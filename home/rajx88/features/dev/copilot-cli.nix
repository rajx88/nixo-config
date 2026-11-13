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
    pkgs.copilot-cli
    # Generated at build time instead of spawning copilot on every shell init.
    (mkZshCompletion "copilot" pkgs.copilot-cli "copilot" "completion zsh")
  ];

  home.persistence."/persist".directories = [
    ".copilot" # auth, sessions, memories
  ];
}
