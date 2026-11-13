{ pkgs, ... }: {
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

  # awscli2 ships a proper zsh completion (_aws with a #compdef header), so it
  # needs no wiring. aws-sso-util has none, so generate it through Click.
  programs.zsh.initContent = ''
    eval "$(_AWS_SSO_UTIL_COMPLETE=zsh_source aws-sso-util)"
  '';
}
