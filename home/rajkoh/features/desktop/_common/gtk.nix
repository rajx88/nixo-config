{
  config,
  pkgs,
  inputs,
  ...
}: {
  gtk = {
    enable = true;
    iconTheme = {
      name = "Papirus";
      package = pkgs.papirus-icon-theme;
    };
  };

  services.xsettingsd = {
    enable = true;
  };

  xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-gtk];
}
