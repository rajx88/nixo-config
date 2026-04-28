# Backup & Restore

## Overview

Your home directory under `/persist/home/<user>` is backed up hourly to Google Drive
using **restic** (deduplication, encryption, compression) and **rclone** (Google Drive
transport). No root required for any operations.

| Setting    | Value                                         |
| ---------- | --------------------------------------------- |
| What       | `/persist/home/<user>` (home directory)       |
| Where      | Google Drive via rclone                       |
| Schedule   | Hourly                                        |
| Retention  | 24 hourly, 7 daily, 4 weekly, 6 monthly      |
| Encryption | AES-256 (restic)                              |
| Dedup      | Content-defined chunking (restic)             |
| Credentials| `~/.config/backup/` (password), `~/.config/rclone/` (rclone config) |

### Default Exclusions

Browser and Electron app caches under `.config/` are excluded by default (they are
regenerated on app launch and waste backup bandwidth). See `modules/nixos/backup.nix`
for the full list. Override via `host.backup.exclude` if needed.

## How It Works

```
/persist/home/<user> -> restic (dedup + encrypt + compress) -> rclone -> Google Drive
```

- **restic** splits files into variable-length chunks, deduplicates them, encrypts
  with AES-256, and compresses. After the first full upload, subsequent backups only
  upload changed chunks (typically a few MB).
- **rclone** handles the Google Drive transport. No FUSE mount needed -- restic talks
  to rclone directly via its backend.
- The systemd timer `restic-backups-persist.timer` triggers hourly. Missed runs are
  caught up on next boot (`Persistent=true`).
- The service runs as your user (not root). `--one-file-system` prevents traversing
  into unexpected btrfs subvolumes.

Configuration lives in `modules/nixos/backup.nix` and is enabled per-host.

## The `persist-backup` CLI

A wrapper script that handles all common operations. No sudo needed. Available on any
host with `host.backup.enable = true`.

```
persist-backup <command> [args]

Commands:
  snapshots          List available snapshots
  backup             Trigger a backup now
  logs               Follow backup progress in journal
  restore [snap]     Restore home (default: latest)
  restore-path <path> [snap]  Restore specific path
  ls [snap]          List files in a snapshot
  mount <dir>        Mount snapshots as FUSE filesystem
  diff <id1> <id2>   Show diff between two snapshots
  status             Show backup service status
  check              Verify backup integrity
  size               Show backup size on remote
  help               Show this help
```

## Enabling on a New Host

### 1. Add config to the host's `default.nix`

```nix
host.backup = {
  enable = true;
  user = "rajx88";  # user whose home to back up
  rclone-remote = "gdrive:<hostname>";
};
```

### 2. Rebuild

```bash
nh os switch
```

### 3. Create restic password

```bash
mkdir -p ~/.config/backup
chmod 700 ~/.config/backup
echo -n "$(openssl rand -base64 32)" > ~/.config/backup/restic-password
chmod 600 ~/.config/backup/restic-password
```

**Save this passphrase in your password manager immediately:**

```bash
cat ~/.config/backup/restic-password
```

Without this passphrase, backups cannot be restored. Ever.

### 4. Configure rclone for Google Drive

```bash
rclone config
```

Follow the prompts:
1. `n` -- new remote
2. Name: `gdrive`
3. Storage type: `drive` (Google Drive)
4. `client_id` / `client_secret` -- press Enter (use defaults)
5. Scope: `3` (access files created by rclone only)
6. `root_folder_id` -- paste the folder ID from your Google Drive URL to restrict
   rclone to a specific folder (recommended)
7. Follow the OAuth browser prompts
8. Shared Drive: `n` (no)

Verify access:

```bash
rclone lsd gdrive:
```

### 5. Initialize the restic repository

```bash
RCLONE_CONFIG=~/.config/rclone/rclone.conf \
  restic -r rclone:gdrive:$(hostname) \
  --password-file ~/.config/backup/restic-password \
  init
```

### 6. Run the first backup

```bash
persist-backup backup
persist-backup logs  # follow progress
```

## Restore

### List available snapshots

```bash
persist-backup snapshots
```

### Restore everything

```bash
persist-backup restore
```

This restores all files to their original absolute paths (e.g., `/persist/home/...`).
Uses the latest snapshot by default.

### Restore a specific snapshot

```bash
persist-backup restore <snapshot-id>
```

### Restore specific directories only

```bash
persist-backup restore-path /persist/home/rajx88/.ssh
```

### Browse snapshots before restoring

```bash
# List files in the latest snapshot
persist-backup ls

# Mount all snapshots as a browsable FUSE filesystem
persist-backup mount /tmp/restic
# Then browse: ls /tmp/restic/snapshots/latest/persist/home/
# Ctrl-C to unmount
```

### Compare two snapshots

```bash
persist-backup diff <snapshot-id-1> <snapshot-id-2>
```

### Restore from a live USB

If the system won't boot, boot a NixOS live USB:

```bash
# Install tools
nix-shell -p restic rclone

# Open LUKS
cryptsetup open /dev/disk/by-label/crypted crypted

# Mount persist
mkdir -p /mnt/persist
mount -o subvol=persist,compress=zstd,noatime /dev/mapper/crypted /mnt/persist

# Restore using credentials from the mounted volume
RCLONE_CONFIG=/mnt/persist/home/<user>/.config/rclone/rclone.conf \
  restic -r rclone:gdrive:<hostname> \
  --password-file /mnt/persist/home/<user>/.config/backup/restic-password \
  restore latest --target /mnt
```

If `/persist` was completely wiped and credentials are lost, you need the restic
passphrase from your password manager and must re-configure rclone:

```bash
nix-shell -p restic rclone

# Re-configure rclone
rclone config
# Set up gdrive remote again (follow OAuth prompts)

# Restore using passphrase from password manager
restic -r rclone:gdrive:<hostname> \
  --password-file <(echo -n 'your-passphrase-from-password-manager') \
  restore latest --target /mnt
```

## Maintenance

### Check backup status

```bash
persist-backup status
```

### Trigger a manual backup

```bash
persist-backup backup
```

### Follow backup progress in journal

```bash
persist-backup logs
```

### Verify backup integrity

```bash
persist-backup check
```

### Check backup size on Google Drive

```bash
persist-backup size
```
