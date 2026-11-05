{ pkgs, ... }: {
  home.packages = [ pkgs.pi-coding-agent ];

  # CodeGraph tools come from the pi extension installed by
  # features/dev/codegraph.nix, not from MCP.

  home.persistence."/persist".directories = [
    ".pi"
  ];
}
