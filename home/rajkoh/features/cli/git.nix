{
  pkgs,
  config,
  ...
}: {
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
        contents = {
          user = {
            email = "rajkohlen@gmail.com";
            name = "rajkohlen";
          };

          core.sshCommand = "ssh -i ${config.home.homeDirectory}/.ssh/id_ed25519";
        };
      }
    ];
  };
}
