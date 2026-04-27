{
  config,
  lib,
  ...
}: let
  monitors = config.monitors;
  enabledMonitors = lib.filter (m: m.enabled) monitors;
in {
  wayland.windowManager.mango.settings = {
    # monitorrule=name:REGEX,width:W,height:H,refresh:R[,x:PX,y:PY,scale:S]
    # parse position "NxN" string for explicit x/y; skip auto-* positions
    monitorrule = map (
      m: let
        parts = lib.splitString "x" m.position;
        hasExplicitPos = builtins.length parts == 2 && builtins.match "[0-9]+" (builtins.elemAt parts 0) != null;
        px = builtins.elemAt parts 0;
        py = builtins.elemAt parts 1;
        posStr = lib.optionalString hasExplicitPos ",x:${px},y:${py}";
      in "name:^${m.name}$,width:${toString m.width},height:${toString m.height},refresh:${toString m.refreshRate}${posStr},scale:1"
    ) enabledMonitors;
  };
}
