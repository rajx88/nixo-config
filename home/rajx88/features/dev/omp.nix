{
  pkgs,
  lib,
  config,
  ...
}: let
  # The radar MCP server is only reachable where features/dev/radar.nix runs the
  # daemon (yuji, which has cluster access). Gate on that package so a host
  # without it (akarnae) doesn't point omp at a dead endpoint.
  hasRadar = lib.any (p: p ? pname && p.pname == "radar") config.home.packages;

  radarServerEntry = lib.optionalString hasRadar ''
    ,
        "radar": {
          "type": "http",
          "url": "http://localhost:9280/mcp"
        }'';
in {
  home.packages = [pkgs.omp pkgs.bun];

  # omp-native user MCP config (discovered at ~/.omp/agent/mcp.json).
  # These servers are also declared in opencode.nix; omp reads this file
  # with higher precedence (native config beats OpenCode discovery).
  home.file.".omp/agent/mcp.json".text = ''
    {
      "$schema": "https://raw.githubusercontent.com/can1357/oh-my-pi/main/packages/coding-agent/src/config/mcp-schema.json",
      "mcpServers": {
        "codegraph": {
          "command": "codegraph",
          "args": ["serve", "--mcp"]
        }${radarServerEntry}
      }
    }
  '';

  programs.fish.interactiveShellInit = ''
    omp completions fish | source
  '';

  home.persistence."/persist".directories = [
    ".omp"
  ];
}
