{inputs, config, ...}: let
  home = config.home.homeDirectory;
in {
  imports = [
    inputs.noctalia.homeModules.default
  ];

  programs.noctalia = {
    enable = true;
    settings = {
      shell = {
        font_family = "Atkinson Hyperlegible Mono";
      };

      wallpaper = {
        enabled = true;
        directory = "${home}/.local/share/wallpapers";
        default.path = "${home}/.local/share/wallpapers/wall-01.jpg";
      };

      theme = {
        mode = "dark";
        source = "wallpaper";
      };

      weather.enabled = true;

      dock.enabled = false;

      widget = {
        clock.format = "{:%H:%M:%S}";
        control-center.glyph = "north-star";
        network.show_label = false;
        sysmon.stat = "ram_pct";
        workspaces.hide_when_empty = true;
        ram.stat = "ram_pct";
      };

      bar = {
        order = ["default"];
        default = {
          position = "top";
          background_opacity = 0.69;
          capsule = false;
          # margin_ends = 10;
          # margin_edge = 10;

          start = ["launcher" "cpu" "ram" "temp" "wallpaper" "media"];
          center = ["workspaces" "clipboard"];
          end = [
            "tray"
            "notifications"
            "network"
            "bluetooth"
            "volume"
            "brightness"
            "battery"
            "clock"
            "control-center"
            "session"
          ];
        };
      };
    };
  };

  home.persistence."/persist".directories = [
    ".cache/noctalia"
    ".local/state/noctalia"
  ];
}
