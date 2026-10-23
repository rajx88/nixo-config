{
  pkgs,
  lib,
  config,
  ...
}:
let
  swaylockPkg = pkgs.swaylock-effects;
  swaylock = "${swaylockPkg}/bin/swaylock";
  pactl = "${pkgs.pulseaudio}/bin/pactl";
  brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl";
  wlopm = "${pkgs.wlopm}/bin/wlopm";

  # The home-manager swayidle unit sets PATH to bash's own bin dir only, so
  # anything invoked from a timeout has to be an absolute store path.
  awk = "${pkgs.gawk}/bin/awk";
  xargs = "${pkgs.findutils}/bin/xargs";
  grep = "${pkgs.gnugrep}/bin/grep";
  systemctl = "${pkgs.systemd}/bin/systemctl";

  isDischarging = "${grep} -q Discharging /sys/class/power_supply/BAT*/status 2>/dev/null";

  lockTime = config.idle.lockTimeout;

  # Retry wrapper for wlopm — the Nvidia legacy driver sometimes drops
  # the wlr-output-power-management request; a second attempt 2s later
  # significantly reduces the failure window.
  # Must be writeShellApplication: writeShellScript yields a single file, so
  # the `${wlopmOff}/bin/...` references below resolved to "Not a directory".
  wlopmOff = pkgs.writeShellApplication {
    name = "wlopm-off";
    runtimeInputs = [
      pkgs.wlopm
      pkgs.gnugrep
      pkgs.util-linux
      pkgs.coreutils
    ];
    text = ''
      logger -t swayidle-dpms "Turning DPMS off"
      wlopm --off '*' 2>&1 | logger -t swayidle-dpms || true
      # Only retry when the output is still on: a blind sleep would block
      # swayidle (-w) and delay the first input after wake.
      if wlopm 2>/dev/null | grep -q ' on$'; then
        logger -t swayidle-dpms "Output still on, retrying"
        sleep 1
        wlopm --off '*' 2>&1 | logger -t swayidle-dpms || true
      fi
    '';
  };

  wlopmOn = pkgs.writeShellApplication {
    name = "wlopm-on";
    runtimeInputs = [
      pkgs.wlopm
      pkgs.util-linux
    ];
    text = ''
      logger -t swayidle-dpms "Turning DPMS on"
      wlopm --on '*' 2>&1 | logger -t swayidle-dpms || true
    '';
  };

  afterLockTimeout =
    {
      timeout,
      command,
      resumeCommand ? null,
    }:
    [
      {
        timeout = lockTime + timeout;
        inherit command resumeCommand;
      }
    ];

  commonArgs = "--clock --indicator --timestr '%k:%M' --datestr '%a %e.%m.%Y' --daemonize";

  lockscreenWp = config.home.sessionVariables.LOCKSCREEN_WP or "";

  mkLockScript =
    {
      grace ? false,
    }:
    let
      graceArg = lib.optionalString grace "--grace 5";
    in
    pkgs.writeShellScriptBin "swaylock-lock${lib.optionalString grace "-idle"}" ''
      if [ -f "${lockscreenWp}" ]; then
        exec ${swaylock} -i "${lockscreenWp}" ${graceArg} ${commonArgs}
      else
        exec ${swaylock} --screenshots --effect-scale 0.5 --effect-blur 10x3 ${graceArg} ${commonArgs}
      fi
    '';

  lockScriptBin = mkLockScript { grace = false; }; # keybind — no grace
  lockScriptIdleBin = mkLockScript { grace = true; }; # swayidle — 5s grace

  lockCmd = "${lockScriptIdleBin}/bin/swaylock-lock-idle";

  # "Home" is whatever monitor profile is currently applied; read at timeout
  # time so docking/undocking is picked up without restarting swayidle.
  profileLink = "${config.home.homeDirectory}/.config/mango/active-profile.conf";
  atHome = pkgs.writeShellApplication {
    name = "idle-at-home";
    runtimeInputs = [ pkgs.coreutils ];
    text = ''
      profile=$(basename "$(readlink ${lib.escapeShellArg profileLink})" .conf)
      case "$profile" in
        ${lib.concatStringsSep "|" (map lib.escapeShellArg config.idle.homeProfiles)}) exit 0 ;;
      esac
      exit 1
    '';
  };

  lockStages =
    if config.idle.lockTimeoutHome == null then
      [
        {
          timeout = lockTime;
          command = lockCmd;
        }
      ]
    else
      [
        {
          timeout = lockTime;
          command = "if ! ${atHome}/bin/idle-at-home; then ${lockCmd}; fi";
        }
        {
          timeout = config.idle.lockTimeoutHome;
          command = "if ${atHome}/bin/idle-at-home; then ${lockCmd}; fi";
        }
      ];

  # Skip when hypridle is handling idle/lock (e.g. hyprland uses hyprlock/hypridle)
  enabled = !config.services.hypridle.enable;

  # Lock detector: swaylock is up iff the guard passes. Used for the
  # lock-gated "go dark sooner" stage, run at fire time.
  isLocked = pkgs.writeShellApplication {
    name = "idle-is-locked";
    runtimeInputs = [ pkgs.procps ];
    text = ''
      pgrep -x swaylock >/dev/null 2>&1
    '';
  };

  # Screen-off stages. dpmsTimeout applies away from home; at home the screen
  # stays on longer (dpmsTimeoutHome) while the session stays unlocked;
  # whenever the lock screen is up the outputs sleep after dpmsTimeoutLocked.
  dpmsStages =
    (lib.optionals (config.idle.dpmsTimeoutLocked != null)
      [
        {
          timeout = config.idle.dpmsTimeoutLocked;
          command = "if ${isLocked}/bin/idle-is-locked; then ${wlopmOff}/bin/wlopm-off; fi";
          resumeCommand = "${wlopmOn}/bin/wlopm-on";
        }
      ])
    ++ (if config.idle.dpmsTimeoutHome == null then
      [
        {
          timeout = config.idle.dpmsTimeout;
          command = "${wlopmOff}/bin/wlopm-off";
          resumeCommand = "${wlopmOn}/bin/wlopm-on";
        }
      ]
    else
      [
        {
          timeout = config.idle.dpmsTimeout;
          command = "if ! ${atHome}/bin/idle-at-home; then ${wlopmOff}/bin/wlopm-off; fi";
          resumeCommand = "${wlopmOn}/bin/wlopm-on";
        }
        {
          timeout = config.idle.dpmsTimeoutHome;
          command = "if ${atHome}/bin/idle-at-home; then ${wlopmOff}/bin/wlopm-off; fi";
          resumeCommand = "${wlopmOn}/bin/wlopm-on";
        }
      ]);
in
{
  programs.swaylock = lib.mkIf enabled {
    enable = true;
    package = swaylockPkg;
  };

  home.packages = lib.mkIf enabled [
    lockScriptBin
    lockScriptIdleBin
    pkgs.wlopm
  ];

  services.swayidle = lib.mkIf enabled {
    enable = true;
    timeouts =
      # Dim: save brightness
      [
        {
          timeout = 10;
          command = "${brightnessctl} --save";
          resumeCommand = "${brightnessctl} --restore";
        }
      ]
      ++
        # Dim: kbd backlight off
        [
          {
            timeout = 30;
            command = "${brightnessctl} --device '*:kbd_backlight' --save set 0";
            resumeCommand = "${brightnessctl} --device '*:kbd_backlight' --restore";
          }
        ]
      ++
        # Dim: screen 50%
        [
          {
            timeout = 50;
            command = "${brightnessctl} set 50%-";
          }
        ]
      ++
        # Dim: screen another 50%
        [
          {
            timeout = 110;
            command = "${brightnessctl} set 50%-";
          }
        ]
      ++
        # Lock screen (home-aware when lockTimeoutHome is set)
        lockStages
      ++
        # Mute mic (after lock)
        (afterLockTimeout {
          timeout = 10;
          command = "${pactl} list sources short | ${awk} '{print $2}' | ${xargs} -I{} ${pactl} set-source-mute {} yes";
          resumeCommand = "${pactl} list sources short | ${awk} '{print $2}' | ${xargs} -I{} ${pactl} set-source-mute {} no";
        })
      ++
        # Power off outputs (independent of the lock: at home the screen goes
        # dark at 10 min while the session stays unlocked until 30 min;
        # away it goes dark at 5 min)
        dpmsStages
      ++
        # If discharging: suspend
        [
          {
            timeout = 900;
            command = "${isDischarging} && ${systemctl} suspend";
          }
        ];
  };
}
