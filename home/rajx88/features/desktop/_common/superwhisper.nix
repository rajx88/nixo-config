{
  pkgs,
  config,
  ...
}:
let
  superwhisper = "${pkgs.superwhisper}/bin/superwhisper";
in
{
  home.packages = [
    pkgs.superwhisper

    # Makes org.a11y.Bus dbus-activatable in the session. mango offers the app
    # no focused-window info of its own (no Hyprland query, no KWin), so it
    # classifies the paste target through AT-SPI instead: without the bus it
    # cannot tell a terminal from anything else and pastes with Ctrl+V, which
    # terminals ignore.
    pkgs.at-spi2-core
  ];

  # Models, recordings, vocabulary and preferences survive the ephemeral root.
  # Models are large (hundreds of MB up to ~1.5 GB) and are downloaded at
  # runtime, so without this they would be fetched again on every boot.
  home.persistence."/persist".directories = [
    ".local/share/superwhisper"
    ".local/state/superwhisper"
    ".config/superwhisper"
  ];

  # Same unit upstream's installer writes, pointed at the store instead of
  # ~/.local/share. Autostart comes from the mango module, which imports
  # WAYLAND_DISPLAY into the user manager before mango-session.target starts.
  systemd.user.services.superwhisper = {
    Unit = {
      Description = "Superwhisper dictation";
      After = [
        "graphical-session.target"
        "pipewire.service"
      ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${superwhisper} daemon";
      # Give media back after a dictation and release any grabbed input.
      ExecStopPost = [
        "${superwhisper} playback-restore"
        "${superwhisper} desktop-release"
      ];
      Restart = "on-failure";
      RestartSec = 2;
      KillMode = "control-group";
      TimeoutStopSec = 15;
      UMask = "0077";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  xdg.desktopEntries."com.superwhisper.Superwhisper" = {
    name = "Superwhisper";
    comment = "Local and cloud voice-to-text dictation";
    exec = "${superwhisper} settings";
    icon = "superwhisper";
    terminal = false;
    categories = [
      "Utility"
      "Accessibility"
    ];
    startupNotify = false;
    settings = {
      StartupWMClass = "com.superwhisper.Superwhisper";
    };
  };
  # superwhisper:// links from the website (license activation).
  xdg.desktopEntries."superwhisper-url" = {
    name = "Superwhisper License Activation";
    exec = "${superwhisper} open-url %u";
    icon = "superwhisper";
    terminal = false;
    noDisplay = true;
    mimeType = [ "x-scheme-handler/superwhisper" ];
  };

  xdg.mimeApps.defaultApplications."x-scheme-handler/superwhisper" = [ "superwhisper-url.desktop" ];
}
