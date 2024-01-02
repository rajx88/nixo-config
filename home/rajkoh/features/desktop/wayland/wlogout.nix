{pkgs, ...}: let
in {
  xdg.configFile."wlogout/layout".text =
    /*
    json
    */
    ''
      {
          "label" : "shutdown",
          "action" : "systemctl poweroff",
          "text" : "Shutdown"
      }

      {
          "label" : "reboot",
          "action" : "systemctl reboot",
          "text" : "Reboot"
      }
    '';

  home.packages = with pkgs; [
    wlogout
  ];
}
