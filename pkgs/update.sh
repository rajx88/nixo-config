#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq

# update.sh — unified updater for self-maintained binary packages
#
# Usage:
#   ./pkgs/update.sh              # update all packages
#   ./pkgs/update.sh omp opencode worktrunk # update specific packages
#   ./pkgs/update.sh --check      # print outdated without updating

set -euo pipefail

PKGS_DIR="$(realpath "$(dirname "${BASH_SOURCE[0]}")")"
REPO_ROOT="$(realpath "$PKGS_DIR/..")"

# ── Package table ─────────────────────────────────────────────────────────────
# brave-origin: /releases/latest correctly returns the stable (1.91.x) channel;
#   newer 1.92.x/1.93.x are beta/nightly and use -nightly-prefixed asset names.
# worktrunk: fetchFromGitHub + cargoHash — handled in the dedicated section below.

PKG_DIRS=(
  "pi-coding-agent"
  "opencode"
  "omp"
  "codegraph"
  "brave-origin"
)
PKG_REPOS=(
  "earendil-works/pi"
  "anomalyco/opencode"
  "can1357/oh-my-pi"
  "colbymchenry/codegraph"
  "brave/brave-browser"
)
PKG_URLS=(
  "https://github.com/earendil-works/pi/releases/download/v{VERSION}/pi-linux-x64.tar.gz"
  "https://github.com/anomalyco/opencode/releases/download/v{VERSION}/opencode-linux-x64.tar.gz"
  "https://github.com/can1357/oh-my-pi/releases/download/v{VERSION}/omp-linux-x64"
  "https://github.com/colbymchenry/codegraph/releases/download/v{VERSION}/codegraph-linux-x64.tar.gz"
  "https://github.com/brave/brave-browser/releases/download/v{VERSION}/brave-origin_{VERSION}_amd64.deb"
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

nix_sri_unpack() {
  local raw
  raw=$(nix-prefetch-url --unpack "$1" 2>/dev/null)
  nix hash convert --hash-algo sha256 --to sri "$raw"
}

in_filter() {
  [[ ${#FILTER[@]} -eq 0 ]] && return 0
  local f; for f in "${FILTER[@]}"; do [[ "$f" == "$1" ]] && return 0; done
  return 1
}

# ── Main loop ─────────────────────────────────────────────────────────────────
UPDATED=0; SKIPPED=0; FAILED=0

for i in "${!PKG_DIRS[@]}"; do
  pkg="${PKG_DIRS[$i]}"
  repo="${PKG_REPOS[$i]}"
  url_template="${PKG_URLS[$i]}"

  in_filter "$pkg" || continue

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

  URL="${url_template//\{VERSION\}/$LATEST}"
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

# ── Worktrunk (fetchFromGitHub + cargoHash) ───────────────────────────────────
if in_filter "worktrunk"; then
  pkg="worktrunk"
  repo="max-sixty/worktrunk"
  PKG_FILE="$PKGS_DIR/$pkg/default.nix"

  CURRENT=$(grep 'version = ' "$PKG_FILE" | head -1 | sed 's/.*"\(.*\)".*/\1/')
  LATEST=$(github_latest "$repo") || { log_err "$pkg" "failed to fetch latest"; (( FAILED++ )) || true; LATEST=""; }

  if [[ -z "$LATEST" ]]; then
    : # error already counted
  elif [[ "$CURRENT" == "$LATEST" ]]; then
    log_ok "$pkg" "up-to-date ($CURRENT)"
    (( SKIPPED++ )) || true
  else
    log_warn "$pkg" "$CURRENT → $LATEST"
    if ! $CHECK_ONLY; then
      log_info "$pkg" "fetching source hash..."
      SRC_SRI=$(nix_sri_unpack \
        "https://github.com/${repo}/archive/refs/tags/v${LATEST}.tar.gz") || {
        log_err "$pkg" "failed to fetch source hash"
        (( FAILED++ )) || true; SRC_SRI=""
      }
      if [[ -n "$SRC_SRI" ]]; then
        BOGUS="sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="
        sed -i "s/version = \"$CURRENT\"/version = \"$LATEST\"/g"          "$PKG_FILE"
        sed -i "s|rev = \"v$CURRENT\"|rev = \"v$LATEST\"|"                  "$PKG_FILE"
        sed -i "s|VERGEN_GIT_DESCRIBE = \"v$CURRENT\"|VERGEN_GIT_DESCRIBE = \"v$LATEST\"|" "$PKG_FILE"
        sed -i "s|hash = \"sha256-.*\"|hash = \"$SRC_SRI\"|"                "$PKG_FILE"
        sed -i "s|cargoHash = \"sha256-.*\"|cargoHash = \"$BOGUS\"|"        "$PKG_FILE"

        log_info "$pkg" "resolving cargoHash (downloads dependencies)..."
        BUILD_OUT=$(cd "$REPO_ROOT" && nix build .#worktrunk 2>&1 || true)
        CARGO_SRI=$(printf '%s' "$BUILD_OUT" | sed -n 's/.*got:[[:space:]]*\(sha256-[^[:space:]]*\).*/\1/p' | head -1)

        if [[ -z "$CARGO_SRI" ]]; then
          log_err "$pkg" "could not determine cargoHash — fix manually in $PKG_FILE"
          (( FAILED++ )) || true
        else
          sed -i "s|cargoHash = \"$BOGUS\"|cargoHash = \"$CARGO_SRI\"|" "$PKG_FILE"
          log_ok "$pkg" "updated to $LATEST"
          (( UPDATED++ )) || true
        fi
      fi
    fi
  fi
fi

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
echo -e "  ${GREEN}${UPDATED} updated${RESET}  ${CYAN}${SKIPPED} up-to-date${RESET}  ${RED}${FAILED} failed${RESET}"

ALL_PKGS=("${PKG_DIRS[@]}" "worktrunk")
if [[ $UPDATED -gt 0 ]]; then
  echo -e "\nVerify: ${CYAN}nix build $(printf '.#%s ' "${ALL_PKGS[@]}")${RESET}"
fi
