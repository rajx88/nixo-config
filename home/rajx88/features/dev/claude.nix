{...}: {
  programs.claude-code = {
    enable = true;
  };

  # ~/.claude/settings.json is managed manually — plugins mutate it at runtime
  home.persistence."/persist".directories = [
    ".claude"
  ];
}
