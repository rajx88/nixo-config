{config, ...}: {
  programs.claude-code = {
    enable = true;
  };

  programs.zsh.sessionVariables = {
    CLAUDE_CONFIG_DIR = "${config.xdg.configHome}/claude";
  };

  home.persistence."/persist".directories = [
    ".config/claude"
  ];
}
