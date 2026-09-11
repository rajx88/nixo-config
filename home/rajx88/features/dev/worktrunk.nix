{...}: {
  programs.worktrunk = {
    enable = true;
    settings = {
      # worktree-path = ".worktrees/{{ branch | sanitize }}";
      worktree-path = "~/code/worktrees/{{ repo }}/{{ branch | sanitize }}";
      merge.commit = true;
      commit.generation.command = "pi --model github-copilot/claude-sonnet-4.6 --no-tools --no-session --print";
      list.summary = true;
      pre-start = [
        {
          copy-opencode = "ln -sf {{ repo_path }}/.opencode {{ worktree_path }}/.opencode 2>/dev/null || true";
          copy-idea = "ln -sf {{ repo_path }}/.idea {{ worktree_path }}/.idea 2>/dev/null || true";
          copy-claude = "ln -sf {{ repo_path }}/.claude {{ worktree_path }}/.claude 2>/dev/null || true";
          mise-trust = "mise trust {{ worktree_path }} 2>/dev/null || true";
        }
      ];
    };
  };

  # Upstream home-manager ships `programs.worktrunk` with enable/package/settings
  # only, so shell integration stays explicit here.
  programs.zsh.initContent = ''
    eval "$(wt config shell init zsh)"
  '';
  programs.bash.initExtra = ''
    eval "$(wt config shell init bash)"
  '';
  programs.fish.interactiveShellInit = ''
    wt config shell init fish | source
  '';

  programs.zsh.shellAliases = {
    wso = "wt switch --create --execute=opencode";
  };
}
