{
  pkgs,
  ...
}:
{
  # hyprpolkitagent 0.2.0 aborts on start on this machine (hyprgraphics
  # OpenGL assertion: "Couldn't open a gbm fd"), which leaves no graphical
  # polkit agent, so pkexec prompts from keybinds fail. The GNOME GTK agent
  # registers with the same polkit daemon and works on wlroots compositors.
  services.hyprpolkitagent.enable = false;

  systemd.user.services.polkit-gnome = {
    Unit = {
      Description = "PolicyKit authentication agent (GNOME)";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 3;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
