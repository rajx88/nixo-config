{ config, lib, ... }: {
  # Pull in the Hindsight option declaration so hosts only need to import
  # this shared module (coding-agents.nix), not hindsight.nix separately.
  imports = [ ./hindsight.nix ];

  config = {
    # Hindsight backend on/off switch. coding-agents.nix is imported by both
    # yuji and akarnae, so setting it here toggles Hindsight for both hosts at
    # once. The option itself is declared in features/dev/hindsight.nix.
    # Flip to true to re-enable the opencode plugin + omp extension.
    hindsight.enable = false;

    # Shared coding-agent state that no single harness owns, so it lives outside
    # the per-harness modules (opencode.nix, omp.nix, orca.nix, ...):
    #
    #   ~/.hindsight           Hindsight memory runtime + config (opencode AND omp read it)
    #   ~/.agents              cross-agent skills dir — Orca's UI installs skills here
    #   ~/.local/state/skills  that skills CLI's own registry (.skill-lock.json)
    #
    # ~/.hindsight is persisted unconditionally so the memory state survives
    # rebuilds; whether the agents actually read it is gated by config.hindsight.enable
    # (opencode/omp wiring only).
    home.persistence."/persist".directories = [
      ".hindsight"
      ".agents"
      ".local/state/skills"
    ];
  };
}
