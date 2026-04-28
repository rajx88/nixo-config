{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.host.backup;

  persist-backup = pkgs.writeShellScriptBin "persist-backup" ''
    export RCLONE_CONFIG="/var/lib/backup/rclone.conf"
    REPO="rclone:${cfg.rclone-remote}"
    PASSWORD_FILE="/var/lib/backup/restic-password"
    RESTIC_ARGS=(-r "$REPO" --password-file "$PASSWORD_FILE")

    case "''${1:-help}" in
      snapshots)
        ${pkgs.restic}/bin/restic "''${RESTIC_ARGS[@]}" snapshots
        ;;
      backup)
        systemctl start restic-backups-persist.service
        echo "Backup started. Follow progress with: sudo persist-backup logs"
        ;;
      logs)
        journalctl -u restic-backups-persist.service -f -n 20
        ;;
      restore)
        SNAP="''${2:-latest}"
        echo "Restoring /persist from snapshot $SNAP..."
        ${pkgs.restic}/bin/restic "''${RESTIC_ARGS[@]}" restore "$SNAP" --target /
        ;;
      restore-path)
        if [ -z "$2" ]; then
          echo "Usage: persist-backup restore-path <path> [snapshot]"
          exit 1
        fi
        SNAP="''${3:-latest}"
        echo "Restoring $2 from snapshot $SNAP..."
        ${pkgs.restic}/bin/restic "''${RESTIC_ARGS[@]}" restore "$SNAP" --target / --include "$2"
        ;;
      ls)
        SNAP="''${2:-latest}"
        ${pkgs.restic}/bin/restic "''${RESTIC_ARGS[@]}" ls "$SNAP"
        ;;
      mount)
        if [ -z "$2" ]; then
          echo "Usage: persist-backup mount <directory>"
          exit 1
        fi
        mkdir -p "$2"
        ${pkgs.restic}/bin/restic "''${RESTIC_ARGS[@]}" mount "$2"
        ;;
      diff)
        if [ -z "$2" ] || [ -z "$3" ]; then
          echo "Usage: persist-backup diff <snapshot-id-1> <snapshot-id-2>"
          exit 1
        fi
        ${pkgs.restic}/bin/restic "''${RESTIC_ARGS[@]}" diff "$2" "$3"
        ;;
      status)
        systemctl status restic-backups-persist.service
        ;;
      check)
        ${pkgs.restic}/bin/restic "''${RESTIC_ARGS[@]}" check
        ;;
      size)
        ${pkgs.rclone}/bin/rclone size "${cfg.rclone-remote}"
        ;;
      help|*)
        echo "Usage: persist-backup <command> [args]"
        echo ""
        echo "Commands:"
        echo "  snapshots          List available snapshots"
        echo "  backup             Trigger a backup now"
        echo "  logs               Follow backup progress in journal"
        echo "  restore [snap]     Restore /persist (default: latest)"
        echo "  restore-path <path> [snap]  Restore specific path"
        echo "  ls [snap]          List files in a snapshot"
        echo "  mount <dir>        Mount snapshots as FUSE filesystem"
        echo "  diff <id1> <id2>   Show diff between two snapshots"
        echo "  status             Show backup service status"
        echo "  check              Verify backup integrity"
        echo "  size               Show backup size on remote"
        echo "  help               Show this help"
        ;;
    esac
  '';
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
          "**/.cache"
          "/persist/home/*/.config/**/Cache"
          "/persist/home/*/.config/**/Cache_Data"
          "/persist/home/*/.config/**/Code Cache"
          "/persist/home/*/.config/**/GPUCache"
          "/persist/home/*/.config/**/DawnWebGPUCache"
          "/persist/home/*/.config/**/DawnGraphiteCache"
          "/persist/home/*/.config/**/CacheStorage"
          "/persist/home/*/.config/**/ScriptCache"
          "/persist/home/*/.config/**/component_crx_cache"
          "/persist/home/*/.mozilla/**/cache2"
        ];
        description = "Paths to exclude from backup";
      };

      timerConfig = mkOption {
        type = types.attrsOf types.str;
        default = {
          OnCalendar = "hourly";
          Persistent = "true";
          RandomizedDelaySec = "5m";
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
        persist-backup
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
        extraBackupArgs = ["--verbose"];
        repository = "rclone:${cfg.rclone-remote}";
        passwordFile = "/var/lib/backup/restic-password";
        rcloneConfigFile = "/var/lib/backup/rclone.conf";
        inherit (cfg) timerConfig;
        pruneOpts = [
          "--keep-hourly 24"
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
