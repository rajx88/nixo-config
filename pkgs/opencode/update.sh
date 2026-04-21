#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq nix-prefetch common-updater-scripts

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PKG_FILE="$SCRIPT_DIR/default.nix"

# Get current version
CURRENT=$(grep 'version = ' "$PKG_FILE" | head -1 | sed 's/.*"\(.*\)".*/\1/')

# Get latest release from GitHub API
LATEST=$(curl -s https://api.github.com/repos/anomalyco/opencode/releases/latest | jq -r .tag_name | sed 's/^v//')

if [ "$CURRENT" = "$LATEST" ]; then
  echo "opencode already at latest: $CURRENT"
  exit 0
fi

echo "Updating opencode: $CURRENT -> $LATEST"

# Prefetch new hash
URL="https://github.com/anomalyco/opencode/releases/download/v${LATEST}/opencode-linux-x64.tar.gz"
HASH=$(nix-prefetch-url --unpack --type sha256 "$URL" 2>/dev/null)
SRI=$(nix hash convert --hash-algo sha256 --to sri "$HASH")

# Update version
sed -i "s/version = \"$CURRENT\"/version = \"$LATEST\"/" "$PKG_FILE"

# Update hash
sed -i "s|hash = \"sha256-.*\"|hash = \"$SRI\"|" "$PKG_FILE"

echo "Updated to $LATEST with hash $SRI"
echo "Run 'nix build .#opencode' to verify"
