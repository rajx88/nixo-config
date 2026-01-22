#!/usr/bin/env bash
set -euo pipefail

# Preview NixOS updates without touching the live checkout.
# Usage: check-updates.sh [/path/to/flake]
# - Defaults to /etc/nixos if no path is given.
# Output contract:
#   * On success with changes: prints `nix store diff-closures` to stdout.
#   * On success with no changes: prints nothing to stdout.
#   * Status/progress is sent to stderr.

repo_root=${1:-/etc/nixos}
host=${HOSTNAME:-$(hostname)}

log() { echo "$*" >&2; }

require() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Missing dependency: $1" >&2
    exit 1
  }
}

require rsync
require nix
require mktemp

if [ ! -d "$repo_root" ]; then
  log "Flake path not found: $repo_root"
  log "Usage: $0 [/path/to/flake] (default: /etc/nixos)"
  exit 1
fi

repo_root=$(realpath "$repo_root")

old_system=$(readlink -f /nix/var/nix/profiles/system)

workdir=$(mktemp -d)
cleanup() { rm -rf "$workdir"; }
trap cleanup EXIT

# Sync repo into temp dir (exclude heavy/irrelevant dirs)
rsync -a --delete \
  --exclude '.git' \
  --exclude '.direnv' \
  --exclude 'result*' \
  "$repo_root"/ "$workdir"/

cd "$workdir"

log "== Updating flake (temporary copy) =="
if ! nix flake update >/dev/null; then
  log "flake update failed"
  exit 1
fi

log "== Building system for host: $host =="
new_system=$(nix build \
  ".#nixosConfigurations.${host}.config.system.build.toplevel" \
  --no-link --print-out-paths 2>/dev/null | tail -1)

if [ -z "$new_system" ]; then
  log "Build failed"
  exit 1
fi

if [ "$old_system" = "$new_system" ]; then
  # No stdout; useful for scripting
  log "No changes detected (build matches current system)."
  exit 0
fi

log "== Package changes (current -> updated) =="
nix store diff-closures "$old_system" "$new_system"
log "Done. No changes were applied to your real repo or system."