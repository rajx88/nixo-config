{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.host.filesystem.btrfs;
in
  with lib; {
    options = {
      host.filesystem.btrfs = {
        enable = mkOption {
          default = false;
          type = with types; bool;
          description = "Enables settings for a BTRFS installation including snapshots";
        };
      };
    };

    config = mkIf cfg.enable {
      boot = {
        supportedFilesystems = [
          "btrfs"
        ];
      };

      fileSystems = {
        "/".options = ["subvol=root" "compress=zstd" "noatime"];
        "/nix".options = ["subvol=nix" "compress=zstd" "noatime"];
      };

      # services = {
      #   btrbk = {
      #     instances."btrbak" = {
      #       onCalendar = "*-*-* *:00:00";
      #       settings = {
      #         timestamp_format = "long";
      #         preserve_day_of_week = "sunday";
      #         preserve_hour_of_day = "0";
      #         snapshot_preserve = "48h 10d 4w 12m 10y";
      #         snapshot_preserve_min = "2d";
      #         volume."/home" = {
      #           snapshot_create = "always";
      #           subvolume = ".";
      #           snapshot_dir = ".snapshots";
      #         };
      #       };
      #     };
      #   };
      # };
    };
  }
