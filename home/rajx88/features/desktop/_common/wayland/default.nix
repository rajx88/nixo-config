{pkgs, ...}: {
  imports = [
    # ./dunst.nix  # replaced by noctalia notifications
    # ./fuzzel.nix  # replaced by noctalia launcher
    # ./swayidle.nix
    # ./swaylock.nix
    ./noctalia.nix
    ./thunar.nix
    # ./waybar  # replaced by noctalia bar
    ./wlogout
  ];

  xdg.mimeApps.enable = true;
  home.packages = with pkgs; [
    grim
    gtk3 # For gtk-launch
    # imv
    # mimeo
    pulseaudio
    slurp
    # waypipe
    # wf-recorder
    wl-clipboard
    # wl-mirror
    # wl-mirror-pick
    # ydotool
  ];

  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = 1;
    LIBSEAT_BACKEND = "logind";
    NIXOS_OZONE_WL = "1";
    QT_QPA_PLATFORM = "wayland";
  };

  xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-wlr];
}
