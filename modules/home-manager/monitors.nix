{
  lib,
  config,
  ...
}: let
  inherit (lib) mkOption mkEnableOption types mkIf;

  monitorSubmodule = types.submodule {
    options = {
      name = mkOption {
        type = types.str;
        example = "DP-1";
      };
      primary = mkOption {
        type = types.bool;
        default = false;
      };
      width = mkOption {
        type = types.int;
        example = 1920;
      };
      height = mkOption {
        type = types.int;
        example = 1080;
      };
      refreshRate = mkOption {
        type = types.int;
        default = 60;
      };
      preferredMode = mkOption {
        type = types.bool;
        default = false;
      };
      isLaptop = mkOption {
        type = types.bool;
        default = false;
      };
      position = mkOption {
        type = types.str;
        default = "auto";
        description = ''
          Monitor placement. Supported values:
            "auto" / "auto-right" — right of previous monitor
            "auto-left"           — left of previous monitor
            "auto-above"          — above previous monitor
            "auto-below"          — below previous monitor
            "center-below"        — centered below previous monitor
            "center-above"        — centered above previous monitor
            "NxN"                 — explicit logical coordinates (e.g. "1920x0")
        '';
      };
      vertical = mkOption {
        type = types.str;
        default = "0";
      };
      enabled = mkOption {
        type = types.bool;
        default = true;
      };
      scale = mkOption {
        type = types.float;
        default = 1.0;
        description = "Scale factor for the monitor (e.g. 1.5 for 150%).";
      };
      bitdepth = mkOption {
        type = types.nullOr (types.enum [8 10]);
        default = null;
      };
      workspaces = mkOption {
        type = types.listOf types.int;
        default = [];
      };
      layout = mkOption {
        type = types.str;
        default = "scroller";
        description = "Default layout for all workspaces on this monitor.";
      };
    };
  };

  cfg = config.monitorProfiles;
in {
  options = {
    monitors = mkOption {
      type = types.listOf monitorSubmodule;
      default = [];
    };

    monitorProfiles = {
      enable = mkEnableOption "monitor profiles";

      default = mkOption {
        type = types.str;
        description = "Name of the default monitor profile to use.";
      };

      profiles = mkOption {
        type = types.attrsOf (types.submodule {
          options = {
            monitors = mkOption {
              type = types.listOf monitorSubmodule;
              default = [];
              description = "Monitor configuration for this profile.";
            };
            detect = {
              externalCount = mkOption {
                type = types.nullOr types.int;
                default = null;
                description = "Number of external monitors expected for auto-detection.";
              };
              resolutions = mkOption {
                type = types.listOf types.str;
                default = [];
                description = "Expected resolutions for auto-detection (e.g. \"3840x2160@120\").";
              };
            };
          };
        });
        default = {};
        description = "Named monitor profiles.";
      };
    };
  };

  config = {
    assertions = [
      {
        assertion =
          ((lib.length config.monitors) != 0)
          -> ((lib.length (lib.filter (m: m.primary) config.monitors)) == 1);
        message = "Exactly one monitor must be set to primary.";
      }
    ] ++ lib.optionals cfg.enable [
      {
        assertion = builtins.hasAttr cfg.default cfg.profiles;
        message = "monitorProfiles.default '${cfg.default}' is not a valid profile name. Available: ${builtins.concatStringsSep ", " (builtins.attrNames cfg.profiles)}";
      }
    ];

    monitors = mkIf cfg.enable cfg.profiles.${cfg.default}.monitors;
  };
}
