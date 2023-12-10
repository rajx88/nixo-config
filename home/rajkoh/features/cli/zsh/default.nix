{
  programs.zsh= {
    enable = true;
    enableCompletion = true;

    zplug = {
      enable = true;
      plugins = [
        { name = "zsh-users/zsh-autosuggestions"; } # Simple plugin installation
        { name = "zsh-users/zsh-syntax-highlighting"; }
        { name= "zsh-users/zsh-completions"; }
        { name= "zsh-users/zsh-autosuggestions"; }
        { name= "romkatv/zsh-defer"; }
        # {name= "Tarrasch/zsh-bd"; }
      ];
    };
  };
}
