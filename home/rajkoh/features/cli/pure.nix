{pkgs, ...}: {
  home.packages = with pkgs; [
    pure-prompt
  ];

  programs.zsh = {
    initContent = ''
      autoload -U promptinit; promptinit
      prompt pure
    '';
  };
}
