{pkgs, ...}: {
  programs.worktrunk = {
    enable = true;
    shellIntegration = {
      zsh = true;
      bash = true;
      fish = true;
    };
    config = {
      # worktree-path = ".worktrees/{{ branch | sanitize }}";
      worktree-path = "../{{ branch | sanitize }}";
      merge = {
        commit = true;
      };
      post-create = {
        copy-opencode = "ln -sf {{ base_worktree_path }}/.opencode {{ worktree_path }}/.opencode 2>/dev/null || true";
        mise-trust = "mise trust {{ worktree_path }} 2>/dev/null || true";
      };
    };
  };
}
