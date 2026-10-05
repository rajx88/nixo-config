{
  inputs,
  pkgs,
  config,
  lib,
  ...
}: let
  monitors = config.monitors;
  primaryMon = lib.findFirst (m: m.primary or false) (builtins.head monitors) monitors;
  notesWidth = primaryMon.width / 2;
  todoWidth = primaryMon.width / 10 * 4;
  fullHeight = primaryMon.height;
  home = config.home.homeDirectory;
in {
  imports = [
    inputs.mango.hmModules.mango

    ../_common
    ../_common/wayland

    ./binds.nix
    ./profiles.nix
    ./lid.nix
  ];

  wayland.windowManager.mango = {
    enable = true;

    settings = {
      # Input
      repeat_rate = 25;
      repeat_delay = 600;
      xkb_rules_layout = "us";
      tap_to_click = true;
      trackpad_natural_scrolling = false;
      mouse_accel_profile = 0;
      trackpad_accel_profile = 0;

      # Focus
      sloppy_focus = true;
      warp_cursor = true;

      # Disable bottom-left hot corner
      enable_hotarea = 0;

      # Master-stack: new windows spawn in stack, not master
      new_is_master = 0;

      # Scroller config
      scroller_default_proportion = 0.5;
      scroller_default_proportion_single = 1.0;
      scroller_ignore_proportion_single = 0;
      scroller_proportion_preset = "0.33,0.5,0.67,1.0";

      # Source the active monitor profile snippet (provides monitorrule, tagrule, workspace binds)
      source_optional = "${home}/.config/mango/active-profile.conf";

      # Window rules — explicit size; no_size_hint bypasses ghostty size constraints
      window_rule = [
        "is_named_scratchpad:1,no_size_hint:1,width:${toString notesWidth},height:${toString fullHeight},app_id:scratchpad.notes"
        "is_named_scratchpad:1,no_size_hint:1,width:${toString todoWidth},height:${toString fullHeight},app_id:scratchpad.todo"
      ];
    };

    # NOTE: the mango hm-module unconditionally emits `exec-once=...` (hyphen),
    # but the 1407fcf binary only accepts `exec_once` (underscore). We therefore
    # avoid `autostart_sh` and wire autostart ourselves.
    extraConfig = ''
      exec_once = ~/.config/mango/autostart.sh
    '';

    bottomPrefixes = ["source_optional"];

    systemd.enable = true;
  };

  xdg.configFile."mango/autostart.sh" = {
    executable = true;
    text = ''
      wl-clip-persist --clipboard regular --reconnect-tries 0 &
      wl-paste --type text --watch cliphist store &
      noctalia &
      mprofile auto &
    '';
  };

  # Polkit agent (wayland-native, works with any wlroots compositor)
  services.hyprpolkitagent.enable = true;
}
