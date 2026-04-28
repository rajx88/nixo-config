{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.host.backup;
in
  with lib; {
    options.host.backup = {
      enable = mkEnableOption "Restic backup to cloud storage via rclone";

      rclone-remote = mkOption {
        type = types.str;
        default = "";
        example = "gdrive:backups/hostname";
        description = "Rclone remote and path for the restic repository";
      };

      exclude = mkOption {
        type = types.listOf types.str;
        default = [
          "/persist/.snapshots"
        ];
        description = "Paths to exclude from backup";
      };

      timerConfig = mkOption {
        type = types.attrsOf types.str;
        default = {
          OnCalendar = "daily";
          Persistent = "true";
          RandomizedDelaySec = "1h";
        };
        description = "Systemd timer configuration for backup schedule";
      };
    };

    config = mkIf cfg.enable {
      assertions = [
        {
          assertion = cfg.rclone-remote != "";
          message = "host.backup.rclone-remote must be set when backup is enabled";
        }
      ];

      environment.systemPackages = with pkgs; [
        restic
        rclone
      ];

      # Persist backup credentials
      environment.persistence."/persist" = mkIf config.host.filesystem.impermanence.enable {
        directories = [
          {
            directory = "/var/lib/backup";
            mode = "0700";
          }
        ];
      };

      services.restic.backups.persist = {
        paths = ["/persist"];
        exclude = cfg.exclude;
        repository = "rclone:${cfg.rclone-remote}";
        passwordFile = "/var/lib/backup/restic-password";
        rcloneConfigFile = "/var/lib/backup/rclone.conf";
        inherit (cfg) timerConfig;
        pruneOpts = [
          "--keep-daily 7"
          "--keep-weekly 4"
          "--keep-monthly 6"
        ];
        backupPrepareCommand = ''
          # Ensure backup credentials exist
          if [ ! -f /var/lib/backup/restic-password ]; then
            echo "ERROR: /var/lib/backup/restic-password not found. Create it with:"
            echo "  echo -n 'your-passphrase' | sudo tee /var/lib/backup/restic-password"
            echo "  sudo chmod 600 /var/lib/backup/restic-password"
            exit 1
          fi
          if [ ! -f /var/lib/backup/rclone.conf ]; then
            echo "ERROR: /var/lib/backup/rclone.conf not found. Create it with:"
            echo "  sudo rclone config --config /var/lib/backup/rclone.conf"
            exit 1
          fi
        '';
      };
    };
  }
