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
      sloppyfocus = true;
      warpcursor = true;

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
      source-optional = "${home}/.config/mango/active-profile.conf";

      # Window rules — explicit size; isnosizehint bypasses ghostty size constraints
      windowrule = [
        "isnamedscratchpad:1,isnosizehint:1,width:${toString notesWidth},height:${toString fullHeight},appid:scratchpad.notes"
        "isnamedscratchpad:1,isnosizehint:1,width:${toString todoWidth},height:${toString fullHeight},appid:scratchpad.todo"
      ];
    };

    autostart_sh = ''
      wl-clip-persist --clipboard regular --reconnect-tries 0 &
      wl-paste --type text --watch cliphist store &
      noctalia &
      mprofile auto &
    '';

    bottomPrefixes = ["source-optional"];

    systemd.enable = true;
  };

  # Polkit agent (wayland-native, works with any wlroots compositor)
  services.hyprpolkitagent.enable = true;
}
