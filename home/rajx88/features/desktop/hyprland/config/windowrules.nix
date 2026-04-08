{...}: {
  wayland.windowManager.hyprland.settings = {
    windowrule = [
      # Notes scratchpad
      "workspace special:notes silent, match:class ^(scratchpad\\.notes)$"

      # Todo scratchpad
      "workspace special:todo silent, match:class ^(scratchpad\\.todo)$"
    ];
  };
}
