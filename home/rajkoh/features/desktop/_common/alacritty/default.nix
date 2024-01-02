{config, ...}: {
  xdg.configFile."alacritty" = {
    source = ./config;
    recursive = true;
  };

  # xdg.configFile."alacritty/alacritty.toml".text =
  #   /*
  #   toml
  #   */
  #   ''
  #     [window]
  #     # opacity = 0.9
  #     # decorations_theme_variant = "Dark"
  #     startup_mode = "Maximized"

  #     [font]
  #     normal = {
  #       family = "${config.fontProfiles.monospace.family}",
  #       style = "Regular",
  #     }
  #     bold = {
  #       family = "${config.fontProfiles.monospace.family}",
  #       style = "Bold",
  #     }
  #     italic = {
  #       family = "${config.fontProfiles.monospace.family}",
  #       style = "Italic",
  #     }

  #     # TokyoNight Alacritty Colors
  #     # [colors]
  #     # indexed_colors = [
  #     #   { index = "16", color = "0xff9e64" },
  #     #   { index = "17", color = "0xdb4b4b" },
  #     # ]

  #     # # Default colors
  #     # [colors.primary]
  #     # background = "0x1a1b26"
  #     # foreground = "0xc0caf5"

  #     # # Normal colors
  #     # [colors.normal]
  #     # black = "0x15161e"
  #     # red = "0xf7768e"
  #     # green = "0x9ece6a"
  #     # yellow = "0xe0af68"
  #     # blue = "0x7aa2f7"
  #     # magenta = "0xbb9af7"
  #     # cyan = "0x7dcfff"
  #     # white = "0xa9b1d6"

  #     # # Bright colors
  #     # [colors.bright]
  #     # black = "0x414868"
  #     # red = "0xf7768e"
  #     # green = "0x9ece6a"
  #     # yellow = "0xe0af68"
  #     # blue = "0x7aa2f7"
  #     # magenta = "0xbb9af7"
  #     # cyan = "0x7dcfff"
  #     # white = "0xc0caf5"

  #   '';

  programs.alacritty = {
    enable = true;
    settings = {
      import = [
        "${config.xdg.configHome}/alacritty/tokyonight-night.yml"
      ];

      # window = {
      #   opacity = 0.9;
      #   decorations_theme_variant = "Dark";
      #   startup_mode = "Maximized";
      # };

      font = {
        # size = 10;

        normal = {
          family = "${config.fontProfiles.monospace.family}";
          style = "Regular";
        };
        bold = {
          family = "${config.fontProfiles.monospace.family}";
          style = "Bold";
        };
        italic = {
          family = "${config.fontProfiles.monospace.family}";
          style = "Italic";
        };
      };
    };
  };
}
