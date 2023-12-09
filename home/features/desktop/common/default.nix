{
  imports = [
    ./1password.nix
    ./alacritty.nix
    ./discord.nix
    ./firefox.nix
    ./font.nix
    ./gtk.nix
    ./qt.nix
    ./wezterm.nix
  ];
  xdg = {
    portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-wlr
        xdg-desktop-portal-gtk
      ];
    };
  };
}
