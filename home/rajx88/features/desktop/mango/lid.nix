{
  config,
  lib,
  pkgs,
  ...
}: let
  monitors = config.monitors;
  isLaptopFlag = lib.any (m: (m.isLaptop or false)) monitors;
  internalPanel = let
    m = lib.findFirst (m: lib.hasPrefix "eDP" m.name) null monitors;
  in
    if m != null
    then m.name
    else "eDP-1";

  wlr-randr = "${pkgs.wlr-randr}/bin/wlr-randr";

  lidCloseScript = pkgs.writeShellScript "mango-lid-close" ''
    LOGFILE=$HOME/.lid-event-debug.log
    echo "[$(date)] mango lid-close handler called" >> "$LOGFILE"

    # Count active monitors via wlr-randr
    active_monitors=$(${wlr-randr} | grep -c "Enabled: yes" || true)

    on_battery=false
    if command -v upower >/dev/null 2>&1; then
      if upower -i $(upower -e | grep BAT) | grep -q "state.*discharging"; then
        on_battery=true
      fi
    fi

    # Don't disable if eDP is only monitor
    if [ "$active_monitors" -le 1 ]; then
      echo "[$(date)] Only 1 monitor active, not disabling" >> "$LOGFILE"
      exit 0
    fi

    if [ "$on_battery" = true ]; then
      echo "[$(date)] On battery, skipping (likely suspending)" >> "$LOGFILE"
      exit 0
    fi

    ${wlr-randr} --output ${internalPanel} --off >> "$LOGFILE" 2>&1
    echo "[$(date)] lid-close handler finished" >> "$LOGFILE"
  '';

  lidOpenScript = pkgs.writeShellScript "mango-lid-open" ''
    ${wlr-randr} --output ${internalPanel} --on
  '';
in {
  # switchbind=fold,cmd  → on lid close
  # switchbind=unfold,cmd → on lid open
  # Note: requires HandleLidSwitch=ignore in logind (set at NixOS level)
  wayland.windowManager.mango.settings = lib.mkIf isLaptopFlag {
    switchbind = [
      "fold,spawn,${lidCloseScript}"
      "unfold,spawn,${lidOpenScript}"
    ];
  };

  home.packages = lib.mkIf isLaptopFlag [pkgs.wlr-randr];
}
