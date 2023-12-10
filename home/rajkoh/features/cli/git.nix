{ pkgs, ... }:
{
  programs.git = {
    enable = true;
    package = pkgs.gitAndTools.gitFull;
    userName = "rajkohlen";
    userEmail = "rajkohlen@gmail.com";
    extraConfig = {
      init.defaultBranch = "main";
    };
    lfs.enable = true;
  };
}
