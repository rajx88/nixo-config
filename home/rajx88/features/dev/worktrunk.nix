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
      merge.commit = true;
      commit.generation.command = "opencode run -m github-copilot/claude-sonnet-4.6 --variant fast";
      list.summary = true;
      post-create = {
        copy-opencode = "ln -sf {{ primary_worktree_path }}/.opencode {{ worktree_path }}/.opencode 2>/dev/null || true";
        copy-idea = "ln -sf {{ primary_worktree_path }}/.idea {{ worktree_path }}/.idea 2>/dev/null || true";
        mise-trust = "mise trust {{ worktree_path }} 2>/dev/null || true";
      };
    };
  };

  programs.zsh.shellAliases = {
    wso = "wt switch --create --execute=opencode";
  };
}
