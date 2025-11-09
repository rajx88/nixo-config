{
  pkgs,
  config,
  ...
}: {
  # home.packages = with pkgs; [
  #   dunst
  # ];

  services.dunst = {
    enable = true;
    inherit (config.gtk) iconTheme;
    settings = {
      global = {
        alignment = "center";
        corner_radius = 16;
        follow = "mouse";
        font = config.fontProfiles.regular.name;
        format = "<b>%s</b>\\n%b";
        frame_width = 1;
        offset = "5x5";
        horizontal_padding = 8;
        icon_position = "left";
        indicate_hidden = "yes";
        markup = "yes";
        max_icon_size = 64;
        mouse_left_click = "do_action";
        mouse_middle_click = "close_all";
        mouse_right_click = "close_current";
        padding = 8;
        plain_text = "no";
        separator_color = "auto";
        separator_height = 1;
        show_indicators = false;
        shrink = "no";
        word_wrap = "yes";
      };

      # TokyoNight colors for dunst
      # For more configuraion options see https://github.com/dunst-project/dunst/blob/master/dunstrc

      urgency_low = {
        background = "#16161e";
        foreground = "#c0caf5";
        frame_color = "#c0caf5";
      };

      urgency_normal = {
        background = "#1a1b26";
        foreground = "#c0caf5";
        frame_color = "#c0caf5";
      };

      urgency_critical = {
        background = "#292e42";
        foreground = "#db4b4b";
        frame_color = "#db4b4b";
      };

      fullscreen_delay_everything = {fullscreen = "delay";};
    };
  };
}
