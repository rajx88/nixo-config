{pkgs, ...}: {
  home.packages = [pkgs.herdr];

  # ~/.config/herdr holds config.toml (including the first-run `onboarding = false`
  # marker) and session.json; ~/.local/state/herdr holds the agent-detection and
  # client-shell state. Off the ephemeral root they are wiped every boot, which
  # makes herdr replay the first-run overlay and forget saved workspaces.
  home.persistence."/persist".directories = [
    ".config/herdr"
    ".local/state/herdr"
  ];
}
