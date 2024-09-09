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
    aliases = {
      c = "commit -v";
      cm = "commit -m";
      all = "add .";
      rall = "reset";
      co = "checkout";
      cob = "checkout -b";
      ra = "rebase --abort";
      pr = "pull --rebase";
      p = "pull";
      pu = "push";
      s = "status";
    };
    includes = [
      {
        condition = "gitdir:~/code/work/";
        path = "${config.xdg.configHome}/git/work.inc";
      }
      {
        condition = "gitdir:~/code/prvt/";
        contentSuffix = "prvt-gitconfig";
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
