#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq

# update.sh — unified updater for self-maintained binary packages
#
# Usage:
#   ./pkgs/update.sh              # update all packages
#   ./pkgs/update.sh omp opencode # update specific packages
#   ./pkgs/update.sh --check      # print outdated without updating

set -euo pipefail

PKGS_DIR="$(realpath "$(dirname "${BASH_SOURCE[0]}")")"

# ── Package table ─────────────────────────────────────────────────────────────
# Not included: worktrunk (two cargo hashes), brave-origin (deb + complex rpath)

PKG_DIRS=(   "pi-coding-agent"  "opencode"          "omp"                "codegraph"          )
PKG_REPOS=(  "earendil-works/pi" "anomalyco/opencode" "can1357/oh-my-pi"  "colbymchenry/codegraph" )
PKG_URLS=(
  "https://github.com/earendil-works/pi/releases/download/v{VERSION}/pi-linux-x64.tar.gz"
  "https://github.com/anomalyco/opencode/releases/download/v{VERSION}/opencode-linux-x64.tar.gz"
  "https://github.com/can1357/oh-my-pi/releases/download/v{VERSION}/omp-linux-x64"
  "https://github.com/colbymchenry/codegraph/releases/download/v{VERSION}/codegraph-linux-x64.tar.gz"
)

# ── Argument parsing ──────────────────────────────────────────────────────────
CHECK_ONLY=false
FILTER=()

for arg in "$@"; do
  if [[ "$arg" == "--check" ]]; then
    CHECK_ONLY=true
  else
    FILTER+=("$arg")
  fi
done

# ── Helpers ───────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; RESET='\033[0m'

log_info() { echo -e "${CYAN}[${1}]${RESET} ${2}"; }
log_ok()   { echo -e "${GREEN}[${1}]${RESET} ${2}"; }
log_warn() { echo -e "${YELLOW}[${1}]${RESET} ${2}"; }
log_err()  { echo -e "${RED}[${1}]${RESET} ${2}" >&2; }

github_latest() {
  curl -sf "https://api.github.com/repos/${1}/releases/latest" \
    | jq -r '.tag_name' | sed 's/^v//'
}

nix_sri() {
  local raw
  raw=$(nix-prefetch-url "$1" 2>/dev/null)
  nix hash convert --hash-algo sha256 --to sri "$raw"
}

# ── Main loop ─────────────────────────────────────────────────────────────────
UPDATED=0; SKIPPED=0; FAILED=0

for i in "${!PKG_DIRS[@]}"; do
  pkg="${PKG_DIRS[$i]}"
  repo="${PKG_REPOS[$i]}"
  url_template="${PKG_URLS[$i]}"

  # Apply filter
  if [[ ${#FILTER[@]} -gt 0 ]]; then
    match=false
    for f in "${FILTER[@]}"; do [[ "$pkg" == "$f" ]] && match=true && break; done
    $match || continue
  fi

  PKG_FILE="$PKGS_DIR/$pkg/default.nix"

  if [[ ! -f "$PKG_FILE" ]]; then
    log_err "$pkg" "default.nix not found: $PKG_FILE"
    (( FAILED++ )) || true; continue
  fi

  CURRENT=$(grep 'version = ' "$PKG_FILE" | head -1 | sed 's/.*"\(.*\)".*/\1/')
  LATEST=$(github_latest "$repo") || {
    log_err "$pkg" "failed to fetch latest from $repo"
    (( FAILED++ )) || true; continue
  }

  if [[ "$CURRENT" == "$LATEST" ]]; then
    log_ok "$pkg" "up-to-date ($CURRENT)"
    (( SKIPPED++ )) || true; continue
  fi

  log_warn "$pkg" "$CURRENT → $LATEST"
  $CHECK_ONLY && continue

  URL="${url_template/\{VERSION\}/$LATEST}"
  log_info "$pkg" "fetching hash..."

  SRI=$(nix_sri "$URL") || {
    log_err "$pkg" "failed to hash $URL"
    (( FAILED++ )) || true; continue
  }

  sed -i "s/version = \"$CURRENT\"/version = \"$LATEST\"/" "$PKG_FILE"
  sed -i "s|hash = \"sha256-.*\"|hash = \"$SRI\"|" "$PKG_FILE"

  log_ok "$pkg" "updated to $LATEST"
  (( UPDATED++ )) || true
done

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
echo -e "  ${GREEN}${UPDATED} updated${RESET}  ${CYAN}${SKIPPED} up-to-date${RESET}  ${RED}${FAILED} failed${RESET}"

if [[ $UPDATED -gt 0 ]]; then
  echo -e "\nVerify: ${CYAN}nix build $(printf '.#%s ' "${PKG_DIRS[@]}")${RESET}"
fi
