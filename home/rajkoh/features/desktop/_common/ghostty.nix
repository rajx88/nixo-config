{
  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      term = "xterm-256color";
      # theme = Fairyfloss
      # theme = heeler
      theme = "rose-pine";
      # theme = catppuccin-macchiato
      # theme = Aura
      # theme = flow-pink
      # theme = Builtin Pastel Dark

      mouse-hide-while-typing = true;
      # window-decoration = false
      background-opacity = 0.9;

      font-family = "ProggyVector";
      font-size = 12;

      keybind = [
        # splits
        "ctrl+shift+\=new_split:right"
        "ctrl+shift+-=new_split:down"
        # navigation
        "ctrl+shift+h=goto_split:left"
        "ctrl+shift+j=goto_split:bottom"
        "ctrl+shift+k=goto_split:top"
        "ctrl+shift+l=goto_split:right"
      ];
    };
  };
}
