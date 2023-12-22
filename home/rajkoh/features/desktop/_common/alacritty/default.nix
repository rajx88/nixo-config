{config, ...}: {
  # xdg = {
  #   configFile."alacritty" = {
  #     source = ./config;
  #     recursive = true;
  #   };
  # };

  programs.alacritty = {
    enable = true;
    settings = {
      # import = [
      #   "~/.config/alacritty/rose-pine.yml"
      # ];

      window = {
        opacity = 0.9;
        decorations_theme_variant = "Dark";
        startup_mode = "Maximized";
      };

      font = {
        normal = {
          family = config.fontProfiles.monospace.family;
          style = "Regular";
        };
        bold = {
          family = config.fontProfiles.monospace.family;
          style = "Bold";
        };
        italic = {
          family = config.fontProfiles.monospace.family;
          style = "Italic";
        };
      };
    };
  };
}
