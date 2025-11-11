{config, ...}: {
  home.persistence."/persist".directories = [
    ".local/share/antidote"
  ];

  programs.zsh = {
    sessionVariables = {
      ANTIDOTE_HOME = "${config.xdg.dataHome}/antidote";
    };
    antidote = {
      enable = true;
      plugins = [
        # "romkatv/zsh-defer"
        "mattmc3/ez-compinit"
        "zsh-users/zsh-completions"
        "aloxaf/fzf-tab"
        "zdharma-continuum/fast-syntax-highlighting"
        "zsh-users/zsh-autosuggestions"
        "zsh-users/zsh-history-substring-search"
        # "spaceship-prompt/spaceship-prompt"
      ];
    };
  };
}
