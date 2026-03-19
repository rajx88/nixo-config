{pkgs, ...}: {
  programs.agent-of-empires = {
    enable = true;
    shellIntegration = {
      zsh = true;
      bash = true;
      fish = true;
    };
    config = {
      session.default_tool = "opencode";
      worktree.enabled = true;
      hooks.on_create = [
        "ln -sf ../.opencode .opencode 2>/dev/null || true"
        "ln -sf ../.idea .idea 2>/dev/null || true"
        "mise trust . 2>/dev/null || true"
      ];
    };
  };
}
