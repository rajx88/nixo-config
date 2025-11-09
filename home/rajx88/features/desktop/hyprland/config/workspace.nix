{
  config,
  lib,
  ...
}: {
  wayland.windowManager.hyprland.settings = {
    workspace = lib.flatten (
      map (
        m:
          map (
            ws: "name:${toString ws},monitor:${m.name}"
          )
          m.workspaces
      ) (lib.filter (m: m.enabled && m.workspaces != []) config.monitors)
    );
  };
}
