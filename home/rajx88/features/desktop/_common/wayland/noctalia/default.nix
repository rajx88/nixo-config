{ config, pkgs, ... }:
let
  home = config.home.homeDirectory;
in
{
  programs.noctalia = {
    enable = true;
    settings = {
      shell = {
        font_family = "Atkinson Hyperlegible Mono";
        panel = {
          control_center_placement = "floating";
          # "centered" is not a valid placement in mainline Noctalia
          # (attached | floating); center it via *_position = "center".
          launcher_placement = "floating";
          launcher_position = "center";
          session_placement = "floating";
          session_position = "center";
          wallpaper_placement = "floating";
          wallpaper_position = "center";
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
        # Hand Noctalia's palette to Luciole via a user template writing
        # ~/.config/luciole/colors.toml. The built-in "luciole" template only
        # exists in Noctalia versions newer than 5.5.0; once the installed
        # Noctalia ships it, this can be replaced by
        # builtin_ids = [ "luciole" ] (see docs.noctalia.dev → Templates).
        templates = {
          user.luciole = {
            input_path = "${pkgs.luciole}/share/luciole/templates/colors.toml";
            output_path = "$XDG_CONFIG_HOME/luciole/colors.toml";
          };
        };
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
        order = [ "default" ];
        default = {
          position = "top";
          background_opacity = 0.69;
          capsule = false;
          # margin_ends = 10;
          # margin_edge = 10;

          start = [
            "launcher"
            "cpu"
            "ram"
            "temp"
            "wallpaper"
            "media"
          ];
          center = [
            "workspaces"
            "clipboard"
          ];
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
