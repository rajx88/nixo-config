{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.host.backup;
  credentialDir = "/persist/secrets/backup";
  backupPath = "/persist/home/${cfg.user}";
  excludeFile = pkgs.writeText "backup-exclude-patterns" (lib.concatStringsSep "\n" cfg.exclude);

  persist-backup = pkgs.writeShellScriptBin "persist-backup" ''
    export RCLONE_CONFIG="${credentialDir}/rclone.conf"
    REPO="rclone:${cfg.rclone-remote}"
    PASSWORD_FILE="${credentialDir}/restic-password"
    RESTIC="${pkgs.restic}/bin/restic"
    RESTIC_ARGS=(-r "$REPO" --password-file "$PASSWORD_FILE")

    case "''${1:-help}" in
      snapshots)
        $RESTIC "''${RESTIC_ARGS[@]}" snapshots
        ;;
      backup)
        echo "Backing up ${backupPath}..."
        $RESTIC "''${RESTIC_ARGS[@]}" backup \
          --verbose --one-file-system \
          --exclude-file=${excludeFile} \
          ${backupPath}
        echo ""
        echo "Pruning old snapshots..."
        $RESTIC "''${RESTIC_ARGS[@]}" forget --prune \
          --keep-hourly 24 --keep-daily 7 --keep-weekly 4 --keep-monthly 6
        echo "Done."
        ;;
      logs)
        sudo journalctl -u restic-backups-persist.service -f -n 50
        ;;
      forget)
        if [ -z "$2" ]; then
          echo "Usage: persist-backup forget <snapshot-id>"
          exit 1
        fi
        echo "Forgetting snapshot $2..."
        $RESTIC "''${RESTIC_ARGS[@]}" forget "$2" --prune
        ;;
      restore)
        SNAP="''${2:-latest}"
        echo "Restoring home from snapshot $SNAP..."
        $RESTIC "''${RESTIC_ARGS[@]}" restore "$SNAP" --target / --verbose=2
        ;;
      restore-path)
        if [ -z "$2" ]; then
          echo "Usage: persist-backup restore-path <path> [snapshot]"
          exit 1
        fi
        SNAP="''${3:-latest}"
        echo "Restoring $2 from snapshot $SNAP..."
        $RESTIC "''${RESTIC_ARGS[@]}" restore "$SNAP" --target / --verbose=2 --include "$2"
        ;;
      ls)
        SNAP="''${2:-latest}"
        $RESTIC "''${RESTIC_ARGS[@]}" ls "$SNAP"
        ;;
      mount)
        if [ -z "$2" ]; then
          echo "Usage: persist-backup mount <directory>"
          exit 1
        fi
        mkdir -p "$2"
        $RESTIC "''${RESTIC_ARGS[@]}" mount "$2"
        ;;
      diff)
        if [ -z "$2" ] || [ -z "$3" ]; then
          echo "Usage: persist-backup diff <snapshot-id-1> <snapshot-id-2>"
          exit 1
        fi
        $RESTIC "''${RESTIC_ARGS[@]}" diff "$2" "$3"
        ;;
      status)
        systemctl status restic-backups-persist.service
        ;;
      check)
        $RESTIC "''${RESTIC_ARGS[@]}" check
        ;;
      size)
        ${pkgs.rclone}/bin/rclone size "${cfg.rclone-remote}"
        ;;
      help|*)
        echo "Usage: persist-backup <command> [args]"
        echo ""
        echo "Commands:"
        echo "  snapshots          List available snapshots"
        echo "  backup             Run a backup now (interactive)"
        echo "  logs               Follow hourly backup progress in journal"
        echo "  forget <id>        Delete a specific snapshot and prune"
        echo "  restore [snap]     Restore home (default: latest)"
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

      user = mkOption {
        type = types.str;
        default = "rajx88";
        description = "User whose home directory to back up";
      };

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
          ".config/**/Cache"
          ".config/**/Cache_Data"
          ".config/**/Code Cache"
          ".config/**/GPUCache"
          ".config/**/DawnWebGPUCache"
          ".config/**/DawnGraphiteCache"
          ".config/**/CacheStorage"
          ".config/**/ScriptCache"
          ".config/**/component_crx_cache"
          ".mozilla/**/cache2"
        ];
        description = "Paths to exclude from backup (relative to backup root)";
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

      environment.persistence."/persist".directories = [
        {
          directory = "secrets/backup";
          mode = "0700";
          user = cfg.user;
          group = "users";
        }
      ];

      services.restic.backups.persist = {
        paths = [backupPath];
        exclude = cfg.exclude;
        extraBackupArgs = ["--verbose" "--one-file-system"];
        repository = "rclone:${cfg.rclone-remote}";
        passwordFile = "${credentialDir}/restic-password";
        rcloneConfigFile = "${credentialDir}/rclone.conf";
        user = cfg.user;
        inherit (cfg) timerConfig;
        pruneOpts = [
          "--keep-hourly 24"
          "--keep-daily 7"
          "--keep-weekly 4"
          "--keep-monthly 6"
        ];
        backupPrepareCommand = ''
          # Ensure backup credentials exist
          if [ ! -f ${credentialDir}/restic-password ]; then
            echo "ERROR: ${credentialDir}/restic-password not found. Create it with:"
            echo "  echo -n 'your-passphrase' > ${credentialDir}/restic-password"
            echo "  chmod 600 ${credentialDir}/restic-password"
            exit 1
          fi
          if [ ! -f ${credentialDir}/rclone.conf ]; then
            echo "ERROR: ${credentialDir}/rclone.conf not found. Create it with:"
            echo "  rclone config --config ${credentialDir}/rclone.conf"
            exit 1
          fi
        '';
      };
    };
  }
