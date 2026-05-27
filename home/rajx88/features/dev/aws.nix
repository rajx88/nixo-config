{pkgs, ...}: {
  home.persistence."/persist" = {
    directories = [
      ".aws"
    ];
  };

  programs.awscli = {
    enable = true;
  };

  home.packages = with pkgs; [
    aws-sso-util
  ];

  programs.zsh.initContent = ''
    # awscli2: register bash-style completer (bashcompinit loaded in zsh.nix)
    # The installed _aws file lacks a #compdef header so compinit skips it
    complete -C ${pkgs.awscli2}/bin/aws_completer aws

    # aws-sso-util: native zsh completion via Click runtime generation
    eval "$(_AWS_SSO_UTIL_COMPLETE=zsh_source aws-sso-util)"
  '';

  programs.fish.interactiveShellInit = ''
    # awscli2: fish completion via aws_completer
    complete -c aws -f -a '(env COMP_LINE=(commandline -cp) aws_completer)'

    # aws-sso-util: fish completion via Click runtime generation
    eval (_AWS_SSO_UTIL_COMPLETE=fish_source aws-sso-util)
  '';
}
