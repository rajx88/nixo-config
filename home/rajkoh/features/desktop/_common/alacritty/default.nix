{config, ...}: {
  xdg.configFile."alacritty" = {
    source = ./config;
    recursive = true;
  };

  programs.alacritty = {
    enable = true;
    settings = {
      general.import = [
        "${config.xdg.configHome}/alacritty/tokyonight-night.toml"
      ];

      window.opacity = 0.85;

      font = {
        # size = 10;

        normal = {
          family = "${config.fontProfiles.monospace.name}";
          style = "Regular";
        };
        bold = {
          family = "${config.fontProfiles.monospace.name}";
          style = "Bold";
        };
        italic = {
          family = "${config.fontProfiles.monospace.name}";
          style = "Italic";
        };
      };
    };
  };
}
