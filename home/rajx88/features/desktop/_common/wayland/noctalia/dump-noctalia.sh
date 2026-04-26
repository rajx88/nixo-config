#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WIDGETS_FILE="$SCRIPT_DIR/noctalia-widgets.json"
LIVE=$(noctalia-shell ipc call state all)

# Dump widgets
echo "$LIVE" | jq .settings.bar.widgets > "$WIDGETS_FILE"
echo "Updated widgets — 'git diff' to see changes"

# Show drift: keys we manage in nix that differ in live
echo ""
echo "=== Runtime drift (add to nix if intentional) ==="
NOCTALIA_BIN=$(readlink -f "$(which noctalia-shell)")
DEFAULTS_FILE="${NOCTALIA_BIN%/bin/*}/share/noctalia-shell/Assets/settings-default.json"

python3 - <<EOF
import json, os

defaults = json.load(open('$DEFAULTS_FILE'))
nix     = json.load(open(os.path.expanduser('~/.config/noctalia/settings.json')))
live    = json.loads('$(echo "$LIVE" | jq -c ".settings | del(.bar.widgets)")')

def merge(base, overlay):
    result = dict(base)
    for k, v in overlay.items():
        if k in result and isinstance(result[k], dict) and isinstance(v, dict):
            result[k] = merge(result[k], v)
        else:
            result[k] = v
    return result

expected = merge(defaults, nix)

def diff(live, expected, path=''):
    if isinstance(live, dict) and isinstance(expected, dict):
        for k in expected:          # only walk keys we manage (in expected)
            if k in live:
                diff(live[k], expected[k], f'{path}.{k}' if path else k)
    elif live != expected:
        print(f'  \033[33m{path}\033[0m')
        print(f'    live:     \033[32m{json.dumps(live)[:120]}\033[0m')
        print(f'    expected: \033[31m{json.dumps(expected)[:120]}\033[0m')

diff(live, expected)
EOF
