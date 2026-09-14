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
        }
      }
    }
  '';

  # ICM integration: `icm init` detects Pi (via the `pi` binary / ~/.pi/agent),
  # not omp (~/.omp/agent), so the files it normally generates for Pi / Claude
  # Code are managed here instead:
  #   - icm.ts               -> auto-inject recall + auto-extract tool output
  #   - APPEND_SYSTEM.md     -> persistent-memory instructions (cli mode)
  #   - skills/icm-*.md      -> /icm-recall + /icm-remember (skill mode)
  home.file = {
    ".omp/agent/extensions/icm.ts".source = ./omp-icm.ts;
    ".omp/agent/APPEND_SYSTEM.md".source = ./omp-append-system.md;
    ".omp/agent/skills/icm-recall.md".source = ./omp-skills/icm-recall.md;
    ".omp/agent/skills/icm-remember.md".source = ./omp-skills/icm-remember.md;
  };

  programs.fish.interactiveShellInit = ''
    omp completions fish | source
  '';

  home.persistence."/persist".directories = [
    ".omp"
  ];
}
