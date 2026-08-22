{
  pkgs,
  lib,
  ...
}: {
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
        },
        "engram": {
          "command": "engram",
          "args": ["mcp", "--tools=agent"]
        }
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
