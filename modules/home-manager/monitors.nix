{
  lib,
  config,
  ...
}: let
  inherit (lib) mkOption types;
in {
  options.monitors = mkOption {
    type = types.listOf (
      types.submodule {
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
      }
    );
    default = [];
  };
  config = {
    assertions = [
      {
        assertion =
          ((lib.length config.monitors) != 0)
          -> ((lib.length (lib.filter (m: m.primary) config.monitors)) == 1);
        message = "Exactly one monitor must be set to primary.";
      }
    ];
  };
}
