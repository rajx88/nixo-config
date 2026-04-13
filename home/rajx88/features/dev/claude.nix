{...}: {
  programs.claude-code = {
    enable = true;
  };

  # ~/.claude/settings.json is managed manually — plugins mutate it at runtime
  home.persistence."/persist".directories = [
    ".claude"
  ];

  # ~/.claude.json is the real config file Claude Code reads/writes (not ~/.claude/.claude.json)
  home.persistence."/persist".files = [
    ".claude.json"
  ];
}
