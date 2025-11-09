{pkgs, ...}: {
  home.sessionVariables = {
    QT_STYLE_OVERRIDE = "gtk3";
  };
  qt = {
    enable = true;
    platformTheme = {
      name = "gtk3";
      package = [
        pkgs.qt5.qtbase
        pkgs.qt6.qtbase
      ];
    };
  };
}
