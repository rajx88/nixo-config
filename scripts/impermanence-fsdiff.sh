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
USAGE
  exit 2
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
fi

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
    if [[ -L "$path" ]]; then
      : # symlink: probably handled elsewhere
    elif [[ -d "$path" ]]; then
      : # directory: ignore
    else
      echo "$path"
    fi
  done
