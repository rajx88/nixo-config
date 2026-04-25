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
  home.file.".config/hypr/lid-close-safeguard.sh" = {
    text = ''
      #!/usr/bin/env bash
      LOGFILE=$HOME/.lid-event-debug.log
      echo "[$(date)] lid-close-handler called" >> "$LOGFILE"
      active_monitors=$(hyprctl monitors -j | jq -r '.[] | select(.disabled == false) | .name')
      num_active=$(echo "$active_monitors" | wc -l)
      on_battery=false
      if command -v upower >/dev/null 2>&1; then
        if upower -i $(upower -e | grep BAT) | grep -q "state.*discharging"; then
          on_battery=true
        fi
      fi
      if echo "$active_monitors" | grep -q '^eDP' && [ "$num_active" -eq 1 ]; then
        echo "[$(date)] Only eDP is active, not disabling monitor" >> "$LOGFILE"
        exit 0
      fi
      if [ "$on_battery" = true ]; then
        echo "[$(date)] On battery, not disabling monitor (likely suspending)" >> "$LOGFILE"
        exit 0
      fi
      hyprctl keyword monitor "${internalPanel}, disable" >> "$LOGFILE" 2>&1
      echo "[$(date)] lid-close-handler finished" >> "$LOGFILE"
    '';
    executable = true;
  };

  wayland.windowManager.hyprland.settings = {
    monitor =
      map
      (
        m: "${m.name},${
          if m.enabled
          then
            (if m.preferredMode
            then "preferred,${toString m.position},1,transform,${toString m.vertical}"
            else "${toString m.width}x${toString m.height}@${toString m.refreshRate},${toString m.position},1,transform,${toString m.vertical}")
            + (lib.optionalString (m.bitdepth != null) ",bitdepth,${toString m.bitdepth}")
          else "disable"
        }"
      )
      monitors;

    # Lid rules only if any monitor entry marks the machine as a laptop
    bindl = lib.optionals isLaptopFlag [
      ",switch:on:${lidSwitchName},exec,${config.home.homeDirectory}/.config/hypr/lid-close-safeguard.sh"
      ",switch:off:${lidSwitchName},exec,hyprctl keyword monitor \"${internalPanel}, preferred, auto, 1\""
    ];
  };
}
