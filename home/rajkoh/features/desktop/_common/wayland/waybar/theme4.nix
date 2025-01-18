{
  pkgs,
  lib,
  config,
  ...
}: let
  hasSway = config.wayland.windowManager.sway.enable;
  hasHyprland = config.wayland.windowManager.hyprland.enable;

  pactl = "${pkgs.pulseaudio}/bin/pactl";
  playerctl = "${config.services.playerctld.package}/bin/playerctl";
  fuzzel = "${config.programs.fuzzel.package}/bin/fuzzel";
  wlogout = "${config.programs.wlogout.package}/bin/wlogout";
  thunar = "${pkgs.xfce.thunar}/bin/thunar";

  gtk-launch = "${pkgs.gtk3}/bin/gtk-launch";
  xdg-mime = "${pkgs.xdg-utils}/bin/xdg-mime";
  defaultApp = type: "${gtk-launch} $(${xdg-mime} query default ${type})";

  chromium = "${config.programs.chromium.package}/bin/chromium";

  browser = "${config.programs.firefox.package}/bin/firefox";
  terminal = "${config.programs.ghostty.package}/bin/ghostty";
in {
  programs.waybar = {
    settings = {
      primary = {
        # General Settings

        # Position TOP
        "layer" = "top";
        "margin-top" = 14;
        "margin-bottom" = 0;

        # Position BOTTOM
        # "position"= "bottom";
        # "margin-top"= 0;
        # "margin-bottom"= 14;

        "margin-left" = 0;
        "margin-right" = 0;
        "spacing" = 0;

        # Modules Left
        "modules-left" = [
          "custom/appmenu"
          "group/quicklinks"
          "hyprland/window"
        ];

        # Modules Center
        "modules-center" = [
          "hyprland/workspaces"
        ];

        # Modules Right
        "modules-right" = [
          "custom/updates"
          "pulseaudio"
          "bluetooth"
          "battery"
          "network"
          "group/hardware"
          "custom/cliphist"
          "idle_inhibitor"
          "tray"
          "custom/exit"
          "clock"
        ];

        # Workspaces
        "hyprland/workspaces" = {
          "on-click" = "activate";
          "active-only" = false;
          "all-outputs" = true;
          "format" = "{}";
          "format-icons" = {
            "urgent" = "";
            "active" = "";
            "default" = "";
          };
          "persistent-workspaces" = {
            "*" = 5;
          };
        };

        # Hyprland Window
        "hyprland/window" = {
          "separate-outputs" = true;
        };

        # # Updates Count
        # "custom/updates"= {
        #     "format"= "  {}";
        #     "tooltip-format"= "{}";
        #     "escape"= true;
        #     "return-type"= "json";
        #     "exec"= "~/dotfiles/scripts/updates.sh";
        #     "restart-interval"= 60;
        #     "on-click"= "${terminal} -e ~/dotfiles/scripts/installupdates.sh";
        #     "on-click-right"= "~/dotfiles/.settings/software.sh";
        #     "tooltip"= false;
        # };

        # # Wallpaper
        # "custom/wallpaper"= {
        #     "format"= "";
        #     "on-click"= "~/dotfiles/hypr/scripts/wallpaper.sh select";
        #     "on-click-right"= "~/dotfiles/hypr/scripts/wallpaper.sh";
        #     "tooltip"= false;
        # };

        # Browser Launcher
        "custom/browser" = {
          "format" = "";
          "on-click" = "${browser}";
          "tooltip" = false;
        };

        # Filemanager Launcher
        "custom/filemanager" = {
          "format" = "";
          "on-click" = "${thunar}";
          "tooltip" = false;
        };

        # Rofi Application Launcher
        "custom/appmenu" = {
          # format = "";
          "format" = " ";
          "on-click" = "${fuzzel}";
          "tooltip" = false;
        };

        # Power Menu
        "custom/exit" = {
          "format" = "";
          "on-click" = "${wlogout}";
          "tooltip" = false;
        };

        # Keyboard State
        "keyboard-state" = {
          "numlock" = true;
          "capslock" = true;
          "format" = "{name} {icon}";
          "format-icons" = {
            "locked" = "";
            "unlocked" = "";
          };
        };

        # System tray
        "tray" = {
          "icon-size" = 21;
          "spacing" = 10;
        };

        # Clock
        "clock" = {
          "tooltip-format" = "<big>{=%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
          "format-alt" = "{=%Y-%m-%d}";
        };

        "clock#time" = {
          interval = 1;
          format = "{:%H:%M:%S}";
          tooltip = false;
        };

        "clock#date" = {
          interval = 10;
          format = " {:%e %b %Y}"; # Icon: calendar-alt
          tooltip-format = "{:%e-%m-%Y}";
        };

        # CPU
        "cpu" = {
          "format" = "/ C {usage}% ";
          "on-click" = "${terminal} -e btm";
        };

        # Memory
        "memory" = {
          "format" = "/ M {}% ";
          "on-click" = "${terminal} -e btm";
        };

        # Harddisc space used
        "disk" = {
          "interval" = 30;
          "format" = "D {percentage_used}% ";
          "path" = "/";
          "on-click" = "${terminal} -e btm";
        };

        "hyprland/language" = {
          "format" = "/ K {short}";
        };

        # Group Hardware
        "group/hardware" = {
          "orientation" = "inherit";
          "drawer" = {
            "transition-duration" = 300;
            "children-class" = "not-memory";
            "transition-left-to-right" = false;
          };
          "modules" = [
            "disk"
            "cpu"
            "memory"
            # "hyprland/language"
          ];
        };

        # Network
        "network" = {
          "format" = "{ifname}";
          "format-wifi" = "   {signalStrength}%";
          "format-ethernet" = "  {ifname}";
          "format-disconnected" = "Disconnected";
          "tooltip-format" = " {ifname} via {gwaddri}";
          "tooltip-format-wifi" = "  {ifname} @ {essid}\nIP: {ipaddr}\nStrength: {signalStrength}%\nFreq: {frequency}MHz\nUp: {bandwidthUpBits} Down: {bandwidthDownBits}";
          "tooltip-format-ethernet" = " {ifname}\nIP: {ipaddr}\n up: {bandwidthUpBits} down: {bandwidthDownBits}";
          "tooltip-format-disconnected" = "Disconnected";
          "max-length" = 50;
          "on-click" = "~/dotfiles/.settings/networkmanager.sh";
        };

        # Battery
        "battery" = {
          "states" = {
            # "good"= 95;
            "warning" = 30;
            "critical" = 15;
          };
          "format" = "{icon}   {capacity}%";
          "format-charging" = "  {capacity}%";
          "format-plugged" = "  {capacity}%";
          "format-alt" = "{icon}  {time}";
          # "format-good"= ""; # An empty format will hide the module
          # "format-full"= "";
          "format-icons" = [" " " " " " " " " "];
        };

        # Pulseaudio
        "pulseaudio" = {
          # "scroll-step"= 1; # %, can be a float
          "format" = "{icon} {volume}%";
          "format-bluetooth" = "{volume}% {icon} {format_source}";
          "format-bluetooth-muted" = " {icon} {format_source}";
          "format-muted" = " {format_source}";
          "format-source" = "{volume}% ";
          "format-source-muted" = "";
          "format-icons" = {
            "headphone" = "";
            "hands-free" = "";
            "headset" = "";
            "phone" = "";
            "portable" = "";
            "car" = "";
            "default" = ["" " " " "];
          };
          "on-click" = "pavucontrol";
        };

        # Bluetooth
        "bluetooth" = {
          "format" = " {status}";
          "format-disabled" = "";
          "format-off" = "";
          "interval" = 30;
          "on-click" = "blueman-manager";
        };

        # Other
        "user" = {
          "format" = "{user}";
          "interval" = 60;
          "icon" = false;
        };

        "idle_inhibitor" = {
          "format" = "{icon}";
          "tooltip" = false;
          "format-icons" = {
            "activated" = "Auto lock OFF";
            "deactivated" = "ON";
          };
        };
      };
    };

    style =
      /*
      css
      */
      ''

        /* -----------------------------------------------------
         * Import Pywal colors
         * ----------------------------------------------------- */
        /* @import 'style-light.css'; */

        /* -----------------------------------------------------
         * General
         * ----------------------------------------------------- */

        @define-color backgroundlight @color5;
        @define-color backgrounddark @color11;
        @define-color workspacesbackground1 @color5;
        @define-color workspacesbackground2 @color11;
        @define-color bordercolor @color11;
        @define-color textcolor1 #FFFFFF;
        @define-color textcolor2 #FFFFFF;
        @define-color textcolor3 #FFFFFF;
        @define-color iconcolor #FFFFFF;


        * {
            font-family: "${config.fontProfiles.regular.family}, Fira Sans Semibold", FontAwesome, Roboto, Helvetica, Arial, sans-serif;
            border: none;
            border-radius: 0px;
        }

        window#waybar {
            background-color: rgba(0,0,0,0.8);
            border-bottom: 0px solid #ffffff;
            /* color: #FFFFFF; */
            background: transparent;
            transition-property: background-color;
            transition-duration: .5s;
        }

        /* -----------------------------------------------------
         * Workspaces
         * ----------------------------------------------------- */

        #workspaces {
            background: @workspacesbackground1;
            margin: 2px 1px 3px 1px;
            padding: 0px 1px;
            border-radius: 15px;
            border: 0px;
            font-weight: bold;
            font-style: normal;
            opacity: 0.8;
            font-size: 16px;
            color: @textcolor1;
        }

        #workspaces button {
            padding: 0px 5px;
            margin: 4px 3px;
            border-radius: 15px;
            border: 0px;
            color: @textcolor1;
            background-color: @workspacesbackground2;
            transition: all 0.3s ease-in-out;
            opacity: 0.4;
        }

        #workspaces button.active {
            color: @textcolor1;
            background: @workspacesbackground2;
            border-radius: 15px;
            min-width: 40px;
            transition: all 0.3s ease-in-out;
            opacity:1.0;
        }

        #workspaces button:hover {
            color: @textcolor1;
            background: @workspacesbackground2;
            border-radius: 15px;
            opacity:0.7;
        }

        /* -----------------------------------------------------
         * Tooltips
         * ----------------------------------------------------- */

        tooltip {
            border-radius: 10px;
            background-color: @backgroundlight;
            opacity:0.8;
            padding:20px;
            margin:0px;
        }

        tooltip label {
            color: @textcolor2;
        }

        /* -----------------------------------------------------
         * Window
         * ----------------------------------------------------- */

        #window {
            background: @backgroundlight;
            margin: 5px 15px 5px 0px;
            padding: 2px 10px 0px 10px;
            border-radius: 12px;
            color:@textcolor2;
            font-size:16px;
            font-weight:normal;
            opacity:0.8;
        }

        window#waybar.empty #window {
            background-color:transparent;
        }

        /* -----------------------------------------------------
         * Taskbar
         * ----------------------------------------------------- */

        #taskbar {
            background: @backgroundlight;
            margin: 3px 15px 3px 0px;
            padding:0px;
            border-radius: 15px;
            font-weight: normal;
            font-style: normal;
            opacity:0.8;
            border: 3px solid @backgroundlight;
        }

        #taskbar button {
            margin:0;
            border-radius: 15px;
            padding: 0px 5px 0px 5px;
        }

        /* -----------------------------------------------------
         * Modules
         * ----------------------------------------------------- */

        .modules-left > widget:first-child > #workspaces {
            margin-left: 0;
        }

        .modules-right > widget:last-child > #workspaces {
            margin-right: 0;
        }

        /* -----------------------------------------------------
         * Custom Quicklinks
         * ----------------------------------------------------- */

        #custom-browser,
        #custom-filemanager,
        #custom-teams,
        #custom-chatgpt,
        #custom-wallpaper,
        #custom-wallpaper,


        #custom-wallpaper {
            margin-right:25px;
        }

        /* -----------------------------------------------------
         * Idle Inhibator
         * ----------------------------------------------------- */

        #idle_inhibitor {
            margin-right: 15px;
            font-size: 16px;
            font-weight: bold;
            opacity: 0.8;
            color: @iconcolor;
        }

        #idle_inhibitor.activated {
            background-color: #dc2f2f;
            font-size: 16px;
            color:#ffffff;
            border-radius: 15px;
            padding: 2px 10px 0px 10px;
            margin: 5px 15px 5px 0px;
            opacity:0.8;
        }

        /* -----------------------------------------------------
         * Custom Modules
         * ----------------------------------------------------- */

        #custom-appmenu, #custom-appmenuwlr {
            background-color: @backgrounddark;
            font-size: 16px;
            color: @textcolor1;
            border-radius: 15px;
            padding: 0px 10px 0px 10px;
            margin: 3px 15px 3px 14px;
            opacity:0.8;
            border:3px solid @bordercolor;
        }

        /* -----------------------------------------------------
         * Custom Exit
         * ----------------------------------------------------- */

        #custom-exit {
            margin: 0px 20px 0px 0px;
            padding:0px;
            font-size:20px;
            color: @iconcolor;
        }

        /* -----------------------------------------------------
         * Custom Updates
         * ----------------------------------------------------- */

        #custom-updates {
            background-color: @backgroundlight;
            font-size: 16px;
            color: @textcolor2;
            border-radius: 15px;
            padding: 2px 10px 0px 10px;
            margin: 5px 15px 5px 0px;
            opacity:0.8;
        }

        #custom-updates.green {
            background-color: @backgroundlight;
        }

        #custom-updates.yellow {
            background-color: #ff9a3c;
            color: #FFFFFF;
        }

        #custom-updates.red {
            background-color: #dc2f2f;
            color: #FFFFFF;
        }

        /* -----------------------------------------------------
         * Custom Youtube
         * ----------------------------------------------------- */

        #custom-youtube {
            background-color: @backgroundlight;
            font-size: 16px;
            color: @textcolor2;
            border-radius: 15px;
            padding: 2px 10px 0px 10px;
            margin: 5px 15px 5px 0px;
            opacity:0.8;
        }

        /* -----------------------------------------------------
         * Hardware Group
         * ----------------------------------------------------- */

        #disk,#memory,#cpu,#language {
            margin:0px;
            padding:0px;
            font-size:16px;
            color:@iconcolor;
        }

        #language {
            margin-right:10px;
        }

        /* -----------------------------------------------------
         * Clock
         * ----------------------------------------------------- */

        #clock {
            background-color: @backgrounddark;
            font-size: 16px;
            color: @textcolor1;
            border-radius: 15px;
            padding: 1px 10px 0px 10px;
            margin: 3px 15px 3px 0px;
            opacity:0.8;
            border:3px solid @bordercolor;
        }

        /* -----------------------------------------------------
         * Pulseaudio
         * ----------------------------------------------------- */

        #pulseaudio {
            background-color: @backgroundlight;
            font-size: 16px;
            color: @textcolor2;
            border-radius: 15px;
            padding: 2px 10px 0px 10px;
            margin: 5px 15px 5px 0px;
            opacity:0.8;
        }

        #pulseaudio.muted {
            background-color: @backgrounddark;
            color: @textcolor1;
        }

        /* -----------------------------------------------------
         * Network
         * ----------------------------------------------------- */

        #network {
            background-color: @backgroundlight;
            font-size: 16px;
            color: @textcolor2;
            border-radius: 15px;
            padding: 2px 10px 0px 10px;
            margin: 5px 15px 5px 0px;
            opacity:0.8;
        }

        #network.ethernet {
            background-color: @backgroundlight;
            color: @textcolor2;
        }

        #network.wifi {
            background-color: @backgroundlight;
            color: @textcolor2;
        }

        /* -----------------------------------------------------
         * Bluetooth
         * ----------------------------------------------------- */

        #bluetooth, #bluetooth.on, #bluetooth.connected {
            background-color: @backgroundlight;
            font-size: 16px;
            color: @textcolor2;
            border-radius: 15px;
            padding: 2px 10px 0px 10px;
            margin: 5px 15px 5px 0px;
            opacity:0.8;
        }

        #bluetooth.off {
            background-color: transparent;
            padding: 0px;
            margin: 0px;
        }

        /* -----------------------------------------------------
         * Battery
         * ----------------------------------------------------- */

        #battery {
            background-color: @backgroundlight;
            font-size: 16px;
            color: @textcolor2;
            border-radius: 15px;
            padding: 2px 15px 0px 10px;
            margin: 5px 15px 5px 0px;
            opacity:0.8;
        }

        #battery.charging, #battery.plugged {
            color: @textcolor2;
            background-color: @backgroundlight;
        }

        @keyframes blink {
            to {
                background-color: @backgroundlight;
                color: @textcolor2;
            }
        }

        #battery.critical:not(.charging) {
            background-color: #f53c3c;
            color: @textcolor3;
            animation-name: blink;
            animation-duration: 0.5s;
            animation-timing-function: linear;
            animation-iteration-count: infinite;
            animation-direction: alternate;
        }

        /* -----------------------------------------------------
         * Tray
         * ----------------------------------------------------- */

        #tray {
            padding: 0px 15px 0px 0px;
        }

        #tray > .passive {
            -gtk-icon-effect: dim;
        }

        #tray > .needs-attention {
            -gtk-icon-effect: highlight;
        }

      '';
  };
}
