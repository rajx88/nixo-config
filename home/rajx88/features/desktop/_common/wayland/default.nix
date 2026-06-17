{pkgs, ...}: {
  imports = [
    # ./swayidle.nix
    ./swaylock.nix
    ./noctalia
    ./thunar.nix
    ./fuzzel.nix
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
    wl-clip-persist
    cliphist
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

  xdg.portal = {
    extraPortals = [pkgs.xdg-desktop-portal-wlr];
    config = {
      common = {
        default = ["gtk"];
        "org.freedesktop.impl.portal.ScreenCast" = ["wlr"];
        "org.freedesktop.impl.portal.Screenshot" = ["wlr"];
      };
    };
  };
}
