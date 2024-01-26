{pkgs, ...}: {
  programs.git = {
    enable = true;
    package = pkgs.gitAndTools.gitFull;
    userName = "rajkohlen";
    extraConfig = {
      init.defaultBranch = "main";
    };
    lfs.enable = true;
  };
}
