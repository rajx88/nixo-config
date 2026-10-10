{ ... }: {
  # Shared coding-agent state that no single harness owns, so it lives outside
  # the per-harness modules (opencode.nix, omp.nix, orca.nix, ...):
  #
  #   ~/.hindsight           Hindsight memory runtime + config (opencode AND omp read it)
  #   ~/.agents              cross-agent skills dir — Orca's UI installs skills here
  #   ~/.local/state/skills  that skills CLI's own registry (.skill-lock.json)
  home.persistence."/persist".directories = [
    ".hindsight"
    ".agents"
    ".local/state/skills"
  ];
}
