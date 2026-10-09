{ pkgs, ... }: {
  # Orchestrator.inc (Agent Orchestrator): fleet control plane for coding
  # agents. Owns its own daemon; drives tmux/gh/opencode/claude/codex.
  home.packages = [ pkgs.ao ];

  home.persistence."/persist".directories = [
    ".agent-orchestrator" # daemon runtime/config state
    ".ao" # gh/git path wrappers installed per workspace
    ".config/Agent Orchestrator" # Electron userData (productName)
    ".config/agent-orchestrator" # fallback userData dir name
  ];
}
