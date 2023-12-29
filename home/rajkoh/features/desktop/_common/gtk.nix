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
      name = "rose-pine";
      package = pkgs.rose-pine-gtk-theme;
    };
    iconTheme = {
      name = "rose-pine";
      package = pkgs.rose-pine-icon-theme;
    };
    font = {
      name = config.fontProfiles.regular.family;
      size = 12;
    };
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
