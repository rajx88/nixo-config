{
  config,
  lib,
  ...
}: let
  vaultPath = "${config.home.homeDirectory}/code/prvt/github/second-brain";
in {
  wayland.windowManager.hyprland.settings = {
    workspace =
      lib.flatten (
        map (
          m:
            map (
              ws: "name:${toString ws},monitor:${m.name}"
            )
            m.workspaces
        ) (lib.filter (m: m.enabled && m.workspaces != []) config.monitors)
      )
      ++ [
        "special:notes, on-created-empty:ghostty --class=scratchpad.notes -e zsh -ic 'nvim ${vaultPath}'"
        "special:todo, on-created-empty:ghostty --class=scratchpad.todo -e zsh -ic 'nvim ${vaultPath}/scratchpad.md'"
      ];
  };
}
