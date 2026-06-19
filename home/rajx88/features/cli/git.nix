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
  prvtDirs = [
    "~/code/prvt/"
    "~/code/nix/"
    "~/code/notes/"
  ];
in {
  home.persistence."/persist".directories = [
    ".config/git"
  ];

  home.file.".config/jj/conf.d/prv.toml".text = ''
    --when.repositories = ["~/code/prv/"]
      [user]
      name = "rajx88"
      email = "44810778+rajx88@users.noreply.github.com"
  '';

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
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
      ".pi"
      # jdtls generated files
      ".project"
      ".classpath"
      ".factorypath"
      ".settings/"
      ".codegraph"
    ];
    settings = {
      init.defaultBranch = "main";
      pull.rebase = true;
      rerere.enabled = true;
      branch.sort = "-committerdate";
      maintenance.auto = false;
      maintenance.strategy = "incremental";
    };
    lfs.enable = true;
    includes =
      [
        {
          condition = "gitdir:~/code/wrk/";
          path = "${config.xdg.configHome}/git/work.inc";
        }
      ]
      ++ map (dir: prvtIdentity // {condition = "gitdir:${dir}";}) prvtDirs;
  };
}
