{config, ...}: {
  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      term = "xterm-256color";
      theme = "rose-pine";
      # theme = "Fairyfloss";
      # theme = "heeler";
      # theme = "catppuccin-macchiato";
      # theme = "Aura";
      # theme = "flow-pink";
      # theme = "Builtin Pastel Dark";

      mouse-hide-while-typing = true;
      window-decoration = false;
      background-opacity = 0.85;

      font-family = "${config.fontProfiles.monospace.name}";
      font-size = config.fontProfiles.monospace.size;

      keybind = [
        # splits
        "ctrl+shift+backslash=new_split:right"
        "ctrl+shift+minus=new_split:down"
        # navigation
        "ctrl+shift+h=goto_split:left"
        "ctrl+shift+j=goto_split:bottom"
        "ctrl+shift+k=goto_split:top"
        "ctrl+shift+l=goto_split:right"
      ];
    };
  };
}
