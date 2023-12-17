{pkgs, ...}: {
  imports = [../_common];

  xdg.portal = {
    extraPortals = [pkgs.xdg-desktop-portal-gnome];
  };
}
