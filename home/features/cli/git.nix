{
  programs.git = {
    enable = true;
    package = pkgs.gitAndTools.gitFull;
    aliases = {
      pushall = "!git remote | xargs -L1 git push --all";
      graph = "log --decorate --oneline --graph";
      add-nowhitespace = "!git diff -U0 -w --no-color | git apply --cached --ignore-whitespace --unidiff-zero -";
      gs = "git status";
      gall = "git add .";
      gc = "git commit";
    };
    userName = "rajkohlen";
    userEmail = "rajkohlen@gmail.com";
    extraConfig = {
      init.defaultBranch = "main";
    };
    lfs.enable = true;
  };
}
