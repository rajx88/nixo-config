#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq gh

# update.sh — unified updater for self-maintained binary packages
#
# Usage:
#   ./pkgs/update.sh              # update all packages
#   ./pkgs/update.sh omp opencode # update specific packages
#   ./pkgs/update.sh --check      # print outdated without updating

set -euo pipefail

PKGS_DIR="$(realpath "$(dirname "${BASH_SOURCE[0]}")")"
REPO_ROOT="$(realpath "$PKGS_DIR/..")"

# ── Package table ─────────────────────────────────────────────────────────────
# twg: Atlassian publishes no GitHub releases — handled in the dedicated section below.

# opencode is handled in the dedicated section below: v2 publishes no GitHub
# release assets, so it tracks opencode.ai's CDN manifest instead.
PKG_DIRS=(
  "pi-coding-agent"
  "omp"
  "codegraph"
  "herdr"
  "radar-desktop"
  "radar"
  "t3code"
  "t3code-cli"
)
PKG_REPOS=(
  "earendil-works/pi"
  "can1357/oh-my-pi"
  "colbymchenry/codegraph"
  "herdrdev/herdr"
  "skyhook-io/radar"
  "skyhook-io/radar"
  "pingdotgg/t3code"
  "pingdotgg/t3code"
)
PKG_URLS=(
  "https://github.com/earendil-works/pi/releases/download/v{VERSION}/pi-linux-x64.tar.gz"
  "https://github.com/can1357/oh-my-pi/releases/download/v{VERSION}/omp-linux-x64"
  "https://github.com/colbymchenry/codegraph/releases/download/v{VERSION}/codegraph-linux-x64.tar.gz"
  "https://github.com/herdrdev/herdr/releases/download/v{VERSION}/herdr-linux-x86_64"
  "https://github.com/skyhook-io/radar/releases/download/v{VERSION}/radar-desktop_v{VERSION}_linux_amd64.tar.gz"
  "https://github.com/skyhook-io/radar/releases/download/v{VERSION}/radar_v{VERSION}_linux_amd64.tar.gz"
  "https://github.com/pingdotgg/t3code/releases/download/v{VERSION}/T3-Code-{VERSION}-amd64.deb"
  "https://github.com/pingdotgg/t3code/releases/download/v{VERSION}/t3-{VERSION}-linux-x64.tar.gz"
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

# ── GitHub API auth ───────────────────────────────────────────────────────────
# Unauthenticated api.github.com requests share a 60-per-hour quota per source
# IP — a single run of this script (plus any other GitHub client on the
# machine) exhausts it, after which every lookup returns HTTP 403 and each
# package reports "failed to fetch latest". Authenticate with
# $GITHUB_TOKEN/$GH_TOKEN, else with the credential the gh CLI already stores
# (~5000 req/hour).
GH_AUTH=()
GH_TOKEN_VALUE="${GITHUB_TOKEN:-${GH_TOKEN:-}}"
if [[ -z "$GH_TOKEN_VALUE" ]] && command -v gh >/dev/null 2>&1; then
  GH_TOKEN_VALUE=$(gh auth token 2>/dev/null) || GH_TOKEN_VALUE=""
fi
if [[ -n "$GH_TOKEN_VALUE" ]]; then
  GH_AUTH=(-H "Authorization: Bearer ${GH_TOKEN_VALUE}")
else
  log_warn "github" "no API token (GITHUB_TOKEN/GH_TOKEN or 'gh auth login') — the shared 60 req/hour unauthenticated quota will make lookups fail"
fi

github_latest() {
  local tag
  tag=$(curl -sfL "${GH_AUTH[@]}" "https://api.github.com/repos/${1}/releases/latest" | jq -r '.tag_name') || return 1
  [[ -n "$tag" && "$tag" != "null" ]] || return 1
  printf '%s\n' "${tag#v}"
}

github_latest_strip() {
  local repo="$1"
  local prefix="$2"
  local tag
  tag=$(curl -sfL "${GH_AUTH[@]}" "https://api.github.com/repos/${repo}/releases/latest" | jq -r '.tag_name') || return 1
  [[ -n "$tag" && "$tag" != "null" ]] || return 1
  tag="${tag#${prefix}}"
  printf '%s\n' "${tag#v}"
}

nix_sri() {
  local raw
  raw=$(nix-prefetch-url "$1" 2>/dev/null) || return 1
  [[ -n "$raw" ]] || return 1
  nix hash convert --hash-algo sha256 --to sri "$raw"
}

nix_sri_unpack() {
  local raw
  raw=$(nix-prefetch-url --unpack "$1" 2>/dev/null) || return 1
  [[ -n "$raw" ]] || return 1
  nix hash convert --hash-algo sha256 --to sri "$raw"
}

in_filter() {
  [[ ${#FILTER[@]} -eq 0 ]] && return 0
  local f; for f in "${FILTER[@]}"; do [[ "$f" == "$1" ]] && return 0; done
  return 1
}

# Extract the first regex match (pattern $1) from text (arg $2), stripping
# the "cursor/" prefix. Uses here-strings + builtins only — see the note
# above the cursor section for why piping into head -1/grep -m1 is unsafe
# under `set -o pipefail`.
cursor_extract_version() {
  local pattern="$1" text="$2" all first
  all=$(grep -oP "$pattern" <<< "$text") || return 1
  [[ -n "$all" ]] || return 1
  first=$(head -1 <<< "$all")
  printf '%s\n' "${first#cursor/}"
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

# ── opencode (non-GitHub: opencode.ai CDN manifest) ───────────────────────
if in_filter "opencode"; then
  pkg="opencode"
  PKG_FILE="$PKGS_DIR/$pkg/default.nix"

  CURRENT=$(grep 'version = ' "$PKG_FILE" | head -1 | sed 's/.*"\(.*\)".*/\1/')

  # v2 ships no GitHub release assets. The stable channel record is the CDN
  # manifest, whose per-file entry is version-stamped and carries the sha256,
  # so the artifact URL stays content-addressed.
  MANIFEST=$(curl -sfL https://opencode.ai/update/api/latest/cli/opencode) || MANIFEST=""
  LATEST=$(jq -r '.version // empty' <<<"$MANIFEST" 2>/dev/null) || LATEST=""
  SHA=$(jq -r '.metadata.files["opencode-linux-x64.tar.gz"].sha256 // empty' <<<"$MANIFEST" 2>/dev/null) || SHA=""

  if [[ -z "$LATEST" || -z "$SHA" ]]; then
    log_err "$pkg" "failed to read version/sha256 from the opencode CDN manifest"
    (( FAILED++ )) || true
  elif [[ "$CURRENT" == "$LATEST" ]]; then
    log_ok "$pkg" "up-to-date ($CURRENT)"
    (( SKIPPED++ )) || true
  else
    log_warn "$pkg" "$CURRENT → $LATEST"
    if ! $CHECK_ONLY; then
      SRI=$(nix hash convert --hash-algo sha256 --from base16 --to sri "$SHA") || {
        log_err "$pkg" "failed to convert sha256 to SRI"
        (( FAILED++ )) || true; SRI=""
      }
      if [[ -n "$SRI" ]]; then
        sed -i "s/version = \"$CURRENT\"/version = \"$LATEST\"/" "$PKG_FILE"
        sed -i "s|hash = \"sha256-.*\"|hash = \"$SRI\"|"          "$PKG_FILE"
        log_ok "$pkg" "updated to $LATEST"
        (( UPDATED++ )) || true
      fi
    fi
  fi
fi

# ── ICM (non-table: tag is icm-v*, asset is a prebuilt glibc tarball) ────────
if in_filter "icm"; then
  pkg="icm"
  repo="rtk-ai/icm"
  PKG_FILE="$PKGS_DIR/$pkg/default.nix"

  CURRENT=$(grep 'version = ' "$PKG_FILE" | head -1 | sed 's/.*"\(.*\)".*/\1/')
  # releases/latest skips the repo's icm-dev-v*-rc* prereleases.
  LATEST=$(github_latest_strip "$repo" "icm-") || { log_err "$pkg" "failed to fetch latest"; (( FAILED++ )) || true; LATEST=""; }

  if [[ -z "$LATEST" ]]; then
    : # error already counted
  elif [[ "$CURRENT" == "$LATEST" ]]; then
    log_ok "$pkg" "up-to-date ($CURRENT)"
    (( SKIPPED++ )) || true
  else
    log_warn "$pkg" "$CURRENT → $LATEST"
    if ! $CHECK_ONLY; then
      # fetchurl hashes the downloaded archive, so this must be the file hash
      # (nix_sri) — nix_sri_unpack yields a different value and would fail to build.
      # The glibc asset, not -musl: the embeddings feature dlopens onnxruntime,
      # which a static musl binary cannot do.
      URL="https://github.com/${repo}/releases/download/icm-v${LATEST}/icm-x86_64-unknown-linux-gnu.tar.gz"
      log_info "$pkg" "fetching hash..."
      SRI=$(nix_sri "$URL") || {
        log_err "$pkg" "failed to hash $URL"
        (( FAILED++ )) || true; SRI=""
      }
      if [[ -n "$SRI" ]]; then
        sed -i "s/version = \"$CURRENT\"/version = \"$LATEST\"/" "$PKG_FILE"
        sed -i "s|hash = \"sha256-.*\"|hash = \"$SRI\"|"           "$PKG_FILE"
        log_ok "$pkg" "updated to $LATEST"
        (( UPDATED++ )) || true
      fi
    fi
  fi
fi

# ── Cursor (non-GitHub: follow redirect to immutable URL) ─────────────────────
if in_filter "cursor"; then
  pkg="cursor"
  PKG_FILE="$PKGS_DIR/$pkg/default.nix"

  CURRENT=$(grep 'version = ' "$PKG_FILE" | head -1 | sed 's/.*"\(.*\)".*/\1/')

  # Follow the api2 redirect to get the immutable downloads.cursor.com URL.
  # The redirect URL contains the full semver (e.g. 3.13.21) and a commit hash,
  # making it content-addressed and reproducible.
  IMMUTABLE_URL=$(curl -sLI "https://api2.cursor.sh/updates/download/golden/linux-x64-deb/cursor/${CURRENT}" 2>/dev/null \
    | sed -n 's/^[Ll]ocation: *//p' | tr -d '\r') || IMMUTABLE_URL=""

  if [[ -z "$IMMUTABLE_URL" ]]; then
    log_err "$pkg" "failed to follow cursor redirect"
    (( FAILED++ )) || true
  else
    LATEST=$(printf '%s' "$IMMUTABLE_URL" | grep -oP 'cursor_\K[0-9]+\.[0-9]+\.[0-9]+') || LATEST=""
    if [[ -z "$LATEST" ]]; then
      log_err "$pkg" "failed to extract full version from $IMMUTABLE_URL"
      (( FAILED++ )) || true
    elif [[ "$CURRENT" == "$LATEST" ]]; then
      log_ok "$pkg" "up-to-date ($CURRENT)"
      (( SKIPPED++ )) || true
    else
      log_warn "$pkg" "$CURRENT → $LATEST"
      if ! $CHECK_ONLY; then
        log_info "$pkg" "fetching hash from immutable URL..."
        SRI=$(nix_sri "$IMMUTABLE_URL") || {
          log_err "$pkg" "failed to hash $IMMUTABLE_URL"
          (( FAILED++ )) || true; SRI=""
        }
        if [[ -n "$SRI" ]]; then
          sed -i "s/version = \"$CURRENT\"/version = \"$LATEST\"/" "$PKG_FILE"
          sed -i "s|url = \"https://downloads.cursor.com/production/[^ ]*\"|url = \"$IMMUTABLE_URL\"|" "$PKG_FILE"
          sed -i "s|hash = \"sha256-.*\"|hash = \"$SRI\"|" "$PKG_FILE"
          log_ok "$pkg" "updated to $LATEST"
          (( UPDATED++ )) || true
        fi
      fi
    fi
  fi
fi

# ── TWG (non-GitHub: Atlassian release manifest) ──────────────────────────────
if in_filter "twg"; then
  pkg="twg"
  PKG_FILE="$PKGS_DIR/twg/default.nix"

  CURRENT=$(grep 'version = ' "$PKG_FILE" | head -1 | sed 's/.*"\(.*\)".*/\1/')

  # atlassian/twg-cli publishes no GitHub releases, so the stable channel record
  # is Atlassian's manifest. assets["linux-x64"].url is already stamped with the
  # version, so it stays content-addressed if the asset is ever republished.
  MANIFEST=$(curl -sfL https://teamwork-graph.atlassian.com/cli/manifest.json) || MANIFEST=""
  LATEST=$(jq -r '.version // empty' <<<"$MANIFEST" 2>/dev/null) || LATEST=""
  URL=$(jq -r '.assets["linux-x64"].url // empty' <<<"$MANIFEST" 2>/dev/null) || URL=""

  if [[ -z "$LATEST" || -z "$URL" ]]; then
    log_err "$pkg" "failed to read version/asset URL from the TWG manifest"
    (( FAILED++ )) || true
  elif [[ "$CURRENT" == "$LATEST" ]]; then
    log_ok "$pkg" "up-to-date ($CURRENT)"
    (( SKIPPED++ )) || true
  else
    log_warn "$pkg" "$CURRENT → $LATEST"
    if ! $CHECK_ONLY; then
      log_info "$pkg" "fetching hash..."
      SRI=$(nix_sri "$URL") || {
        log_err "$pkg" "failed to hash $URL"
        (( FAILED++ )) || true; SRI=""
      }
      if [[ -n "$SRI" ]]; then
        sed -i "s/version = \"$CURRENT\"/version = \"$LATEST\"/" "$PKG_FILE"
        sed -i "s|hash = \"sha256-.*\"|hash = \"$SRI\"|"           "$PKG_FILE"
        log_ok "$pkg" "updated to $LATEST"
        (( UPDATED++ )) || true
      fi
    fi
  fi
fi

# ── Orca (non-table: the repo also publishes mobile-* releases) ───────────────
if in_filter "orca-ide"; then
  pkg="orca-ide"
  repo="stablyai/orca"
  PKG_FILE="$PKGS_DIR/$pkg/default.nix"

  CURRENT=$(grep 'version = ' "$PKG_FILE" | head -1 | sed 's/.*"\(.*\)".*/\1/')

  # stablyai/orca tags desktop builds v<semver> and also ships unrelated tags
  # (e.g. mobile-android-v0.0.52), so releases/latest can point at the wrong
  # stream. Pick the newest tag that is exactly v<major>.<minor>.<patch>.
  LATEST=$(curl -sfL "${GH_AUTH[@]}" "https://api.github.com/repos/${repo}/releases?per_page=30" \
    | jq -r '[.[].tag_name | select(test("^v[0-9]+\\.[0-9]+\\.[0-9]+$"))][0] // empty' 2>/dev/null \
    | sed 's/^v//') || LATEST=""

  if [[ -z "$LATEST" ]]; then
    log_err "$pkg" "failed to find a v<semver> release in $repo"
    (( FAILED++ )) || true
  elif [[ "$CURRENT" == "$LATEST" ]]; then
    log_ok "$pkg" "up-to-date ($CURRENT)"
    (( SKIPPED++ )) || true
  else
    log_warn "$pkg" "$CURRENT → $LATEST"
    if ! $CHECK_ONLY; then
      URL="https://github.com/${repo}/releases/download/v${LATEST}/orca-ide_${LATEST}_amd64.deb"
      log_info "$pkg" "fetching hash..."
      SRI=$(nix_sri "$URL") || {
        log_err "$pkg" "failed to hash $URL"
        (( FAILED++ )) || true; SRI=""
      }
      if [[ -n "$SRI" ]]; then
        sed -i "s/version = \"$CURRENT\"/version = \"$LATEST\"/" "$PKG_FILE"
        sed -i "s|hash = \"sha256-.*\"|hash = \"$SRI\"|"           "$PKG_FILE"
        log_ok "$pkg" "updated to $LATEST"
        (( UPDATED++ )) || true
      fi
    fi
  fi
fi

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
echo -e "  ${GREEN}${UPDATED} updated${RESET}  ${CYAN}${SKIPPED} up-to-date${RESET}  ${RED}${FAILED} failed${RESET}"

ALL_PKGS=("${PKG_DIRS[@]}" "opencode" "icm" "cursor" "twg" "orca-ide")
if [[ $UPDATED -gt 0 ]]; then
  echo -e "\nVerify: ${CYAN}nix build $(printf '.#%s ' "${ALL_PKGS[@]}")${RESET}"
fi
