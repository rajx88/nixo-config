{pkgs, ...}: {
  programs.worktrunk = {
    enable = true;
    shellIntegration = {
      zsh = true;
      bash = true;
      fish = true;
    };
    config = {
      worktree-path = ".worktrees/{{ branch | sanitize }}";
      merge = {
        commit = true;
      };
      post-create = {
        copy-opencode = "cp -r {{ base_worktree_path }}/.opencode {{ worktree_path }}/.opencode 2>/dev/null || true";
      };
      post-switch = {
        mise-trust = "mise trust {{ worktree_path }} 2>/dev/null || true";
      };
    };
  };
}
