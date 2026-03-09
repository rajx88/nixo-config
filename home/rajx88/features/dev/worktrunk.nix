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
    };
  };
}
