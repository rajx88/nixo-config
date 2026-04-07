{
  wayland.windowManager.hyprland.settings = {
    windowrule = [
      # Notes scratchpad (vault browser) — right half of screen
      "float on, match:class ^(notes)$"
      "size 50% 100%, match:class ^(notes)$"
      "move 50% 0%, match:class ^(notes)$"
      "workspace special:notes silent, match:class ^(notes)$"

      # Todo scratchpad (todo editor) — right half of screen
      "float on, match:class ^(todo)$"
      "size 50% 100%, match:class ^(todo)$"
      "move 50% 0%, match:class ^(todo)$"
      "workspace special:todo silent, match:class ^(todo)$"
    ];
  };
}
