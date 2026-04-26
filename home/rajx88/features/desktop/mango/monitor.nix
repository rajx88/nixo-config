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
    # x/y omitted → mango auto-arranges
    monitorrule = map (
      m: "name:^${m.name}$,width:${toString m.width},height:${toString m.height},refresh:${toString m.refreshRate},scale:1"
    ) enabledMonitors;
  };
}
