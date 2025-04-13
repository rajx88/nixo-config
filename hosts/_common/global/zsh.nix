{
  programs.zsh = {
    enable = true;
    enableCompletion = false;
    shellAliases = {
      ll = "ls -al";
    };
    histSize = 10000;
  };

  environment = {
    # needed for completion for system packages
    pathsToLink = ["/share/zsh"];
  };
}
