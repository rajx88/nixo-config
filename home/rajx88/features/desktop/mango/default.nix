{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.mango.hmModules.mango

    ../_common
    ../_common/wayland

    ./binds.nix
    ./monitor.nix
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
      accel_profile = 0;

      # Focus
      sloppyfocus = true;
      warpcursor = true;

      # Master-stack: new windows spawn in stack, not master
      new_is_master = 0;

      # Scroller config
      scroller_default_proportion = 0.5;
      scroller_proportion_preset = "0.33,0.5,0.67,1.0";

      # Default layouts per tag: scroller on DP-1 (1-5), tile on DP-2 (6-10)
      tagrule = [
        "id:1,layout_name:scroller"
        "id:2,layout_name:scroller"
        "id:3,layout_name:scroller"
        "id:4,layout_name:scroller"
        "id:5,layout_name:scroller"
        "id:6,layout_name:tile"
        "id:7,layout_name:tile"
        "id:8,layout_name:tile"
        "id:9,layout_name:tile"
        "id:10,layout_name:tile"
      ];

      # Named scratchpad window rules
      windowrule = [
        "isnamedscratchpad:1,width:1280,height:800,appid:scratchpad.notes"
        "isnamedscratchpad:1,width:1280,height:800,appid:scratchpad.todo"
      ];
    };

    autostart_sh = ''
      noctalia-shell &
      ${pkgs.lxqt.lxqt-policykit}/bin/lxqt-policykit-agent &
    '';

    systemd.enable = true;
  };

  # Noctalia idle + lock (hyprland uses hyprlock/hypridle instead)
  programs.noctalia-shell.settings = {
    general = {
      allowPasswordWithFprintd = true;
      lockScreenBlur = 20;
      lockScreenTint = 0.3;
      lockOnSuspend = true;
      clockFormat = "HH\nmm";
    };
    idle = {
      enabled = true;
      screenOffTimeout = 300;
      lockTimeout = 660;
      suspendTimeout = 900;
      fadeDuration = 5;
    };
  };
}
