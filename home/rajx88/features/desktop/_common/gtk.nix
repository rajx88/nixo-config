{
  config,
  pkgs,
  inputs,
  ...
}: rec {
  gtk = {
    enable = true;
    # theme = {
    #   name = "Sweet-mars";
    #   package = pkgs.sweet;
    # };
    theme = {
      name = "Flat-Remix-GTK-Magenta-Dark";
      package = pkgs.flat-remix-gtk;
    };
    iconTheme = {
      name = "Flat-Remix-Magenta-Dark";
      package = pkgs.flat-remix-icon-theme;
    };
    font = {
      name = config.fontProfiles.regular.name;
      size = 12;
    };
  };

  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.apple-cursor;
    name = "macOS";
    size = 24;
  };

  services.xsettingsd = {
    enable = true;
    settings = {
      "Net/ThemeName" = "${gtk.theme.name}";
      "Net/IconThemeName" = "${gtk.iconTheme.name}";
    };
  };

  xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-gtk];
}
