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
      worktree-path = "~/code/worktrees/{{ repo }}/{{ branch | sanitize }}";
      merge.commit = true;
      commit.generation.command = "opencode run -m github-copilot/claude-sonnet-4.6 --variant fast";
      list.summary = true;
      post-create = {
        copy-opencode = "ln -sf {{ repo_path }}/.opencode {{ worktree_path }}/.opencode 2>/dev/null || true";
        copy-idea = "ln -sf {{ repo_path }}/.idea {{ worktree_path }}/.idea 2>/dev/null || true";
        copy-claude = "ln -sf {{ repo_path }}/.claude {{ worktree_path }}/.claude 2>/dev/null || true";
        mise-trust = "mise trust {{ worktree_path }} 2>/dev/null || true";
      };
    };
  };

  programs.zsh.shellAliases = {
    wso = "wt switch --create --execute=opencode";
  };
}
