{pkgs, ...}: {
  programs.git = {
    enable = true;
    package = pkgs.gitAndTools.gitFull;
    extraConfig = {
      init.defaultBranch = "main";
    };
    lfs.enable = true;
    includes = [
      {
        condition = "gitdir:~/code/work/";
        path = "${config.xdg.configHome}/git/work.inc";
      }
      {
        condition = "gitdir:~/code/prvt/";
        path = "${config.xdg.configHome}/git/prvt.inc";
      }
    ];
  };
}
