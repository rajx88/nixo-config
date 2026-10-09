{pkgs, ...}: let
  # Rebuild indexed projects whose graph was built by an older CodeGraph
  # extraction engine. Incremental auto-sync never re-extracts unchanged
  # files, so a `codegraph index` full rebuild is the only way to pick up
  # engine improvements after a version bump. Only projects that already
  # have a `.codegraph` directory are touched — indexing a repo is always a
  # deliberate, per-project action (never auto-init).
  reindexStale = pkgs.writeShellScript "codegraph-reindex-stale" ''
    set -euo pipefail

    mapfile -t indexes < <(${pkgs.findutils}/bin/find "$HOME/code" \
      -type d -name .codegraph -prune 2>/dev/null || true)

    for cg in "''${indexes[@]}"; do
      repo="''${cg%/.codegraph}"
      [ "$repo" = "$HOME" ] && continue

      status="$( (cd "$repo" && ${pkgs.codegraph}/bin/codegraph status --json) 2>/dev/null || true)"
      [ -n "$status" ] || continue

      stale="$(printf '%s' "$status" | ${pkgs.jq}/bin/jq -r '.index.reindexRecommended // false' 2>/dev/null || echo false)"
      if [ "$stale" = "true" ]; then
        echo "reindexing $repo"
        (cd "$repo" && ${pkgs.codegraph}/bin/codegraph index -q) || echo "FAILED: $repo"
      fi
    done
  '';
in {
  home.packages = [pkgs.codegraph];

  systemd.user.services.codegraph-reindex = {
    Unit = {
      Description = "Rebuild stale CodeGraph indexes under ~/code";
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${reindexStale}";
      # Large repos (e.g. eshop-shop-modulith) can take minutes to re-parse.
      Nice = 10;
      IOSchedulingClass = "idle";
      TimeoutStartSec = "infinity";
    };
  };

  systemd.user.timers.codegraph-reindex = {
    Unit = {
      Description = "Daily rebuild of stale CodeGraph indexes";
    };
    Timer = {
      OnBootSec = "10min";
      OnUnitActiveSec = "24h";
      Persistent = true;
    };
    Install = {
      WantedBy = ["timers.target"];
    };
  };
}
