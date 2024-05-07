{
  pkgs,
  config,
  ...
}: let
in {
  xdg.configFile."wlogout" = {
    source = ./icons;
    target = "wlogout/icons";
    recursive = true;
  };

  xdg.configFile."wlogout/layout".text =
    /*
    json
    */
    ''
      {
          "label" : "shutdown",
          "action" : "sleep 0.1; systemctl poweroff",
          "text" : "Shutdown",
          "keybind" : "s"
      }

      {
          "label" : "reboot",
          "action" : "sleep 0.1; systemctl reboot",
          "text" : "Reboot",
          "keybind" : "r"
      }

      {
          "label" : "logout",
          "action" : "sleep 0.1; hyprctl dispatch exit",
          "text" : "Logout",
          "keybind" : "e"
      }
    '';

  xdg.configFile."wlogout/style.css".text =
    /*
    css
    */
    ''
      * {
        font-family: ${config.fontProfiles.monospace.family};
      	background-image: none;
      	transition: 20ms;
      }

      window {
      	background-color: rgba(12, 12, 12, 0.1);
      }

      button {
      	color: #FFFFFF;
          font-size:20px;

          background-repeat: no-repeat;
      	background-position: center;
      	background-size: 25%;

      	border-style: solid;
      	background-color: rgba(12, 12, 12, 0.3);
      	border: 3px solid #FFFFFF;

          box-shadow: 0 4px 8px 0 rgba(0, 0, 0, 0.2), 0 6px 20px 0 rgba(0, 0, 0, 0.19);
      }

      button:focus,
      button:active,
      button:hover {
          color: @color11;
      	background-color: rgba(12, 12, 12, 0.5);
      	border: 3px solid @color11;
      }

      /*
      -----------------------------------------------------
      Buttons
      -----------------------------------------------------
      */

      #lock {
      	margin: 10px;
      	border-radius: 20px;
      	background-image: image(url("icons/lock.png"));
      }

      #logout {
      	margin: 10px;
      	border-radius: 20px;
      	background-image: image(url("icons/logout.png"));
      }

      #suspend {
      	margin: 10px;
      	border-radius: 20px;
      	background-image: image(url("icons/suspend.png"));
      }

      #hibernate {
      	margin: 10px;
      	border-radius: 20px;
      	background-image: image(url("icons/hibernate.png"));
      }

      #shutdown {
      	margin: 10px;
      	border-radius: 20px;
      	background-image: image(url("icons/shutdown.png"));
      }

      #reboot {
      	margin: 10px;
      	border-radius: 20px;
      	background-image: image(url("icons/reboot.png"));
      }
    '';

  home.packages = with pkgs; [
    wlogout
  ];
}
