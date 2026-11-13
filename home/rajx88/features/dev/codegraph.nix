{
  pkgs,
  lib,
  config,
  ...
}:
let
  # pi (and omp, which is a pi fork) get CodeGraph through the
  # `@vndv/pi-codegraph` extension rather than MCP: it registers the full
  # codegraph_* toolset and injects its own usage guidance, where the MCP
  # server only exposes `codegraph_explore`. Both harnesses install extensions
  # imperatively into their own agent dirs, so converge them here instead of
  # leaving a manual step that a fresh system would silently miss.
  codegraphExtension = "npm:@vndv/pi-codegraph@0.1.11";

  hasPi = lib.any (p: (p.pname or "") == "pi-coding-agent") config.home.packages;
  hasOmp = lib.any (p: (p.pname or "") == "omp") config.home.packages;

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
in
{
  home.packages = [ pkgs.codegraph ];

  # Runs on every switch but only installs when the harness's own registry
  # doesn't list the extension yet; failures are non-fatal so an offline
  # switch still succeeds.
  home.activation.codegraphAgentExtensions = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    set -u
    ${lib.optionalString hasPi ''
      piBin=${pkgs.pi-coding-agent}/bin/pi
      if ! "$piBin" list 2>/dev/null | grep -qF "@vndv/pi-codegraph"; then
        echo "codegraph: installing pi extension ${codegraphExtension}"
        # `pi install` shells out to npm, which the activation PATH lacks.
        PATH="${lib.makeBinPath [ pkgs.nodejs_24 ]}:$PATH" \
          "$piBin" install ${codegraphExtension} \
          || echo "codegraph: WARN pi extension install failed (is npm on PATH?)" >&2
      fi
    ''}
    ${lib.optionalString hasOmp ''
      ompBin=${pkgs.omp}/bin/omp
      if ! "$ompBin" plugin list --json 2>/dev/null | grep -qF '"@vndv/pi-codegraph"'; then
        echo "codegraph: installing omp extension ${codegraphExtension}"
        "$ompBin" install ${codegraphExtension} \
          || echo "codegraph: WARN omp extension install failed (network?)" >&2
      fi
    ''}
  '';

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
      WantedBy = [ "timers.target" ];
    };
  };
}
