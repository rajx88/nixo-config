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
        panel = {
          control_center_placement = "floating";
          launcher_placement = "centered";
          session_placement = "centered";
          wallpaper_placement = "centered";
          open_near_click_control_center = true;
          open_near_click_clipboard = true;
          open_near_click_session = true;
          open_near_click_wallpaper = true;
        };
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
        clock.format = "{:%d/%m/%Y %H:%M:%S}";
        control-center.glyph = "north-star";
        network.show_label = false;
        sysmon.stat = "ram_pct";
        workspaces.hide_when_empty = true;
        ram.stat = "ram_pct";
        battery.display_mode = "graphic";
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
