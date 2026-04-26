{
  config,
  lib,
  ...
}: let
  monitors = config.monitors;
in {
  wayland.windowManager.mango.settings = {
    # monitorr=<name>,<width>x<height>@<rate>,<x>,<y>,<scale>
    monitorr = map (
      m: "${m.name},${
        if m.enabled
        then "${toString m.width}x${toString m.height}@${toString m.refreshRate},auto,1"
        else "disable"
      }"
    ) monitors;

    # Tag-to-monitor: tagmon=<tag-index>,<monitor-name>
    # Tags are 0-indexed, workspaces in monitors option are 1-indexed
    tagmon = lib.flatten (map (
      m: map (
        ws: "${toString (ws - 1)},${m.name}"
      ) m.workspaces
    ) monitors);
  };
}
