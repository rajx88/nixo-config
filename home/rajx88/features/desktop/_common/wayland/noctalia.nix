{inputs, config, ...}: {
  imports = [
    inputs.noctalia.homeModules.default
  ];

  programs.noctalia-shell = {
    enable = true;
    settings = {
      bar = {
        position = "top";
        density = "default";
      };
      dock = {
        enabled = false;
      };
      general = {
        enableShadows = true;
        enableBlurBehind = true;
      };
      colorSchemes = {
        predefinedScheme = "Noctalia (default)";
        darkMode = true;
      };
      wallpaper = {
        enabled = true;
        directory = "${config.xdg.dataHome}/wallpapers";
      };
    };
  };

  home.persistence."/persist".directories = [".config/noctalia"];
}
