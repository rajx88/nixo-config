{
  pkgs,
  config,
  ...
}: let
  prvtIdentity = {
    contentSuffix = "prvt-gitconfig";
    contents = {
      user = {
        email = "44810778+rajx88@users.noreply.github.com";
        name = "rajx88";
      };
    };
  };
  prvtDirs = ["~/code/prvt/" "~/code/nix/"];
in {
  home.persistence."/persist".directories = [
    ".config/git"
  ];

  home.file.".config/jj/conf.d/prvt.toml".text = ''
    --when.repositories = ["~/code/prvt/"]
      [user]
      name = "rajx88"
      email = "44810778+rajx88@users.noreply.github.com"
  '';

  programs.jujutsu = {
    enable = false;
    settings = {
      ui = {
        default-command = ["log"];
        paginate = "auto";
        # pager = ":builtin";
      };
      #   name = "rajx88";
      #   email = "44810778+rajx88@users.noreply.github.com";
      # };
    };
  };
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    enableJujutsuIntegration = false;
    options = {
      line-numbers = true;
      side-by-side = true;
    };
  };
  programs.git = {
    enable = true;
    ignores = [
      ".claude"
      ".opencode"
    ];
    settings = {
      extraConfig = {
        init.defaultBranch = "main";
        pull.ff = "only";
        rerere.enable = true;
        branch.sort = "-committerdate";
        maintenance.auto = false;
        maintenance.strategy = "incremental";
      };
    };
    lfs.enable = true;
    includes = [
      {
        condition = "gitdir:~/code/work/";
        path = "${config.xdg.configHome}/git/work.inc";
      }
    ] ++ map (dir: prvtIdentity // {condition = "gitdir:${dir}";}) prvtDirs;
  };
}
