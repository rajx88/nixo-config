{
  config,
  lib,
  ...
}: let
  monitors = config.monitors;

  # true if any monitor entry has isLaptop = true
  isLaptopFlag = lib.any (m: (m.isLaptop or false)) monitors;

  # pick the first eDP-like panel from your list; fallback to "eDP-1"
  internalPanel = let
    m = lib.findFirst (m: lib.hasPrefix "eDP" m.name) null monitors;
  in
    if m != null
    then m.name
    else "eDP-1";

  lidSwitchName = "Lid Switch"; # adjust if Hyprland shows a different name
in {
  wayland.windowManager.hyprland.settings = {
    monitor = let
      waybarSpace = let
        inherit (config.wayland.windowManager.hyprland.settings.general) gaps_in gaps_out;
        inherit (config.programs.waybar.settings.primary) position height width;
        gap = gaps_out - gaps_in;
      in {
        top =
          if position == "top"
          then height + gap
          else 0;
        bottom =
          if position == "bottom"
          then height + gap
          else 0;
        left =
          if position == "left"
          then width + gap
          else 0;
        right =
          if position == "right"
          then width + gap
          else 0;
      };
    in
      [
        ",addreserved,${toString waybarSpace.top},${toString waybarSpace.bottom},${toString waybarSpace.left},${toString waybarSpace.right}"
      ]
      ++ (
        map
        (
          m: "${m.name},${
            if m.enabled
            then
              if m.preferredMode
              then "preferred,${toString m.position},1,transform,${toString m.vertical}"
              else "${toString m.width}x${toString m.height}@${toString m.refreshRate},${toString m.position},1,transform,${toString m.vertical}"
            else "disable"
          }"
        )
        monitors
      );

    # Lid rules only if any monitor entry marks the machine as a laptop
    bindl = lib.optionals isLaptopFlag [
      ",switch:on:${lidSwitchName},exec,hyprctl keyword monitor \"${internalPanel}, disable\""
      ",switch:off:${lidSwitchName},exec,hyprctl keyword monitor \"${internalPanel}, preferred, auto, 1\""
    ];
  };
}
