{pkgs, lib, ...}: {
  home.packages = [pkgs.omp pkgs.bun];

  programs.fish.interactiveShellInit = ''
    omp completions fish | source
  '';

  home.file.".omp/agent/mcp.json" = {
    text = builtins.toJSON {
      "$schema" = "https://raw.githubusercontent.com/can1357/oh-my-pi/main/packages/coding-agent/src/config/mcp-schema.json";
      mcpServers = {
        codegraph = {
          command = lib.getExe pkgs.codegraph;
          args = ["serve" "--mcp"];
        };
      };
    };
  };

  home.persistence."/persist".directories = [
    ".omp"
  ];
}
