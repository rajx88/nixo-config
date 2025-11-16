#!/usr/bin/env bash
set -euo pipefail

# Small robust fs-diff helper for impermanence setups.
# Usage: impermanence-fsdiff [DEVICE_OR_MOUNTPOINT]
# If DEVICE_OR_MOUNTPOINT is a block device (e.g. /dev/nvme0n1p2) the script
# will mount it (subvol=/) into a temporary directory. If it is a mountpoint
# the script will use it directly. If omitted, the script attempts to auto-
# detect the root btrfs device from the current mount table.

cleanup() {
  local rc=$?
  if [[ -n "${_should_mount:-}" && "${_should_mount}" -eq 1 && -n "${_tmp_root:-}" ]]; then
    sudo umount "${_tmp_root}" >/dev/null 2>&1 || true
    rm -rf "${_tmp_root}" || true
  fi
  exit $rc
}
trap cleanup EXIT

usage() {
  cat >&2 <<'USAGE'
Usage: impermanence-fsdiff [DEVICE_OR_MOUNTPOINT]
Lists files that changed in a btrfs root subvolume compared to a blank snapshot.

If DEVICE_OR_MOUNTPOINT is a block device (e.g. /dev/sda2) it will be mounted
with -o subvol=/ into a temporary directory. If the argument is an existing
mountpoint, that mountpoint will be used directly. If omitted, the script will
try to auto-detect the root btrfs device.

Environment variables:
  ROOT_SUBVOL        root subvolume name (default: root)
  BLANK_ROOT_SUBVOL  blank root snapshot name (default: root-blank)

Options:
  -v, --verbose      print debug messages (SKIP/INCLUDE) to stderr
  -t, --targets      show resolved targets for symlinks (path -> target)
      --show-store    include symlinks that resolve into /nix or /nix/store

Notes:
  - Exclude/filtering was removed from this tool. Pipe the output to ripgrep
    (rg -v) or grep -v if you want to filter results, e.g.:
      ./scripts/impermanence-fsdiff.sh --targets | rg -v 'wallpapers'
USAGE
  exit 2
}

VERBOSE=0
PRINT_TARGETS=0
# Hide entries that resolve into the Nix store by default. Use --show-store to
# include them in output when you want to inspect store-backed targets.
HIDE_STORE=1

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
fi

if [[ "${1:-}" == "--verbose" || "${1:-}" == "-v" ]]; then
  VERBOSE=1
  shift
fi

if [[ "${1:-}" == "--targets" || "${1:-}" == "-t" ]]; then
  PRINT_TARGETS=1
  shift
fi

if [[ "${1:-}" == "--show-store" ]]; then
  HIDE_STORE=0
  shift
fi

  # Exclude handling removed; use ripgrep externally if you need filtering.

# write_out was removed when reverting rg-forwarding; we now write directly
# to stdout using echo/printf in-place.

command -v btrfs >/dev/null 2>&1 || { echo "btrfs not found" >&2; exit 1; }
command -v mount >/dev/null 2>&1 || { echo "mount not found" >&2; exit 1; }

ROOT_SUBVOL="${ROOT_SUBVOL:-root}"
BLANK_ROOT_SUBVOL="${BLANK_ROOT_SUBVOL:-root-blank}"

if [[ -n "${1:-}" ]]; then
  arg="$1"
  if [[ -b "$arg" ]]; then
    _mount_drive="$arg"
    _should_mount=1
  elif mountpoint -q "$arg" 2>/dev/null; then
    _tmp_root="$arg"
    _should_mount=0
  else
    echo "Argument is neither a block device nor a mountpoint: $arg" >&2
    exit 1
  fi
else
  # try to auto-detect the device mounted on /
  _mount_drive=$(mount | awk '$3=="/" && $5=="btrfs" { print $1 }' || true)
  if [[ -n "${_mount_drive}" ]]; then
    _should_mount=1
  else
    echo "Could not detect btrfs root device. Provide DEVICE_OR_MOUNTPOINT." >&2
    exit 1
  fi
fi

if [[ "${_should_mount:-0}" -eq 1 ]]; then
  _tmp_root=$(mktemp -d)
  sudo mount -o subvol=/ "${_mount_drive}" "${_tmp_root}" >/dev/null 2>&1
fi

if [[ ! -d "${_tmp_root}/${BLANK_ROOT_SUBVOL}" ]]; then
  echo "Missing blank root subvolume at ${_tmp_root}/${BLANK_ROOT_SUBVOL}" >&2
  exit 1
fi

OLD_TRANSID=$(sudo btrfs subvolume find-new "${_tmp_root}/${BLANK_ROOT_SUBVOL}" 9999999 2>/dev/null || true)
if [[ -z "${OLD_TRANSID:-}" ]]; then
  # No changes or no transid found; nothing to list
  exit 0
fi
OLD_TRANSID=${OLD_TRANSID#transid marker was }

sudo btrfs subvolume find-new "${_tmp_root}/${ROOT_SUBVOL}" "${OLD_TRANSID}" 2>/dev/null |
  sed '$d' |
  cut -f17- -d' ' |
  sort -u |
  while read -r path; do
    path="/$path"
    if [[ -z "$path" ]]; then
      continue
    fi

    # Operate on the mounted root (either temp mount or provided mountpoint)
    target="${_tmp_root}${path}"

    # Exclude patterns: first handle glob patterns (existing behaviour),
    # then regex excludes (prefixed with re: when provided on the CLI).

  # Resolve the target (works for symlinks and regular files) for both the
  # mounted snapshot and the live filesystem so we can detect store-backed
  # targets even when the snapshot and live views differ.
  resolved_snapshot=$(readlink -f "$target" 2>/dev/null || true)
  resolved_live=$(readlink -f "/${path#/}" 2>/dev/null || true)
  # Prefer live resolution for user-visible output when available.
  resolved=${resolved_live:-$resolved_snapshot}

    if [[ -L "$target" || -L "/${path#/}" ]]; then
      # symlink in snapshot or live FS. Determine if it points into /nix.
      if [[ "$HIDE_STORE" -eq 1 && ( ( -n "$resolved_snapshot" && ( "$resolved_snapshot" = */nix/* || "$resolved_snapshot" = */nix/store/* ) ) || ( -n "$resolved_live" && ( "$resolved_live" = */nix/* || "$resolved_live" = */nix/store/* ) ) ) ]]; then
        $([ "$VERBOSE" -eq 1 ] && echo "SKIP (nix/store) $path -> ${resolved:-(unresolved)}" >&2 || true)
        continue
      fi

      if [[ -n "$resolved" ]]; then
        $([ "$VERBOSE" -eq 1 ] && echo "INCLUDE (symlink) $path -> $resolved" >&2 || true)
        if [[ "$PRINT_TARGETS" -eq 1 ]]; then
          echo "$path -> ${resolved:-(unresolved)}"
        else
          echo "$path"
        fi
      else
        $([ "$VERBOSE" -eq 1 ] && echo "INCLUDE (symlink-unresolved) $path" >&2 || true)
        if [[ "$PRINT_TARGETS" -eq 1 ]]; then
          echo "$path -> (unresolved)"
        else
          echo "$path"
        fi
      fi
    else
      # If it's a directory or file in the mounted root, include it unless
      # we've already skipped it above as Nix-managed.
      if [[ -e "$target" ]]; then
        echo "$path"
      else
        # Path reported by btrfs as changed but not present in snapshot mount
        echo "$path"
      fi
    fi
  done
# End of output processing.
