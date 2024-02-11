{pkgs, ...}: {
  home.packages = with pkgs; [
    pure-prompt
  ];

  programs.zsh = {
    initExtra = ''
      autoload -U promptinit; promptinit
      prompt pure
    '';
  };
}
