{inputs, config, ...}: let
  widgets = builtins.fromJSON (builtins.readFile ./noctalia-widgets.json);
  home = config.home.homeDirectory;
in {
  imports = [
    inputs.noctalia.homeModules.default
  ];

  programs.noctalia-shell = {
    enable = true;
    settings = {
      settingsVersion = 59;

      general.avatarImage = "${home}/.face";

      ui = {
        fontDefault = "Atkinson Hyperlegible Mono";
        fontFixed = "monospace";
      };

      appLauncher = {
        enableClipboardHistory = true;
        terminalCommand = "ghostty -e";
      };

      bar = {
        barType = "floating";
        capsuleOpacity = 0;
        widgetSpacing = 10;
        contentPadding = 10;
        backgroundOpacity = 0.69;
        useSeparateOpacity = true;
        mouseWheelAction = "volume";
        middleClickAction = "settings";
        inherit widgets;
      };

      location = {
        weatherEnabled = false;
        showWeekNumberInCalendar = true;
        autoLocate = false;
      };

      calendar.cards = [
        { enabled = true; id = "calendar-header-card"; }
        { enabled = true; id = "calendar-month-card"; }
        { enabled = false; id = "weather-card"; }
      ];

      wallpaper.directory = "${home}/.local/share/wallpapers";

      dock.enabled = false;

      colorSchemes.useWallpaperColors = true;
    };
  };

  home.persistence."/persist".directories = [
    ".config/noctalia"
    ".cache/noctalia"
  ];
}
