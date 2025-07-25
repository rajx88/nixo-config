{
  pkgs,
  config,
  ...
}: {
  home.file.".config/jj/conf.d/prvt.toml".text = ''
    --when.repositories = ["~/code/prvt/"]
      [user]
      name = "rajx88"
      email = "44810778+rajx88@users.noreply.github.com"
  '';

  programs.jujutsu = {
    enable = true;
    settings = {
      ui = {
        default-command = ["log"];
        paginate = "auto";
        pager = ":builtin";
      };
      #   name = "rajx88";
      #   email = "44810778+rajx88@users.noreply.github.com";
      # };
    };
  };
  programs.git = {
    enable = true;
    package = pkgs.gitAndTools.gitFull;
    extraConfig = {
      init.defaultBranch = "main";
      pull.ff = "only";
      rerere.enable = true;
      branch.sort = "-committerdate";
      maintenance.auto = false;
      maintenance.strategy = "incremental";
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
      staash = "stash --all";
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
            email = "44810778+rajx88@users.noreply.github.com";
            name = "rajx88";
          };

          core.sshCommand = "ssh -i ${config.home.homeDirectory}/.ssh/id_ed25519";
        };
      }
    ];
    delta = {
      enable = true;
      options = {
        line-numbers = true;
        side-by-side = true;
      };
    };
  };
}
