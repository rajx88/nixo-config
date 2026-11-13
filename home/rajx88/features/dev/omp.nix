{
  pkgs,
  lib,
  config,
  ...
}:
let
  # The radar MCP server is only reachable where features/dev/radar.nix runs the
  # daemon (yuji, which has cluster access). Gate on that package so a host
  # without it (akarnae) doesn't point omp at a dead endpoint.
  hasRadar = lib.any (p: p ? pname && p.pname == "radar") config.home.packages;

  radarServerEntry = lib.optionalString hasRadar ''
    "radar": {
      "type": "http",
      "url": "http://localhost:9280/mcp"
    }'';

  mkZshCompletion = import ../../lib/zsh-completion.nix { inherit pkgs lib; };
in
{
  home.packages = [
    pkgs.omp
    pkgs.bun
    # Generated at build time instead of spawning omp on every shell init.
    (mkZshCompletion "omp" pkgs.omp "omp" "completions zsh")
  ];

  # omp-native user MCP config (discovered at ~/.omp/agent/mcp.json).
  #
  # CodeGraph is not an MCP server here: omp is a pi fork and gets it from the
  # `@vndv/pi-codegraph` extension, installed by features/dev/codegraph.nix.
  # The CodeGraph MCP server only exposes `codegraph_explore`, so an MCP entry
  # would be a strict subset of the extension's 8 tools.
  home.file = {
    ".omp/agent/mcp.json".text = ''
      {
        "$schema": "https://raw.githubusercontent.com/can1357/oh-my-pi/main/packages/coding-agent/src/config/mcp-schema.json",
        "mcpServers": {
          ${radarServerEntry}
        }
      }
    '';
  }
  // lib.optionalAttrs config.hindsight.enable {
    # Hindsight memory: omp loads the pi bundle of the shared coding-agents
    # runtime (staged by `npx @vectorize-io/hindsight-coding-agents install`
    # into the persisted ~/.hindsight). Kept as an out-of-store symlink so the
    # auto-updater can refresh the bundle without a rebuild.
    ".omp/agent/extensions/hindsight.js".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.hindsight/coding-agents/dist/pi.js";
  };

  home.persistence."/persist".directories = [
    ".omp"
  ];
}
