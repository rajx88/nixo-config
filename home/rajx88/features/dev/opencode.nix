{
  pkgs,
  lib,
  config,
  ...
}: let
  # Same gate as omp.nix: radar's daemon only exists where features/dev/radar.nix
  # is imported (yuji). akarnae has no radar package, so no remote MCP entry.
  hasRadar = lib.any (p: p ? pname && p.pname == "radar") config.home.packages;
in {
  programs.opencode = {
    enable = true;
    package = pkgs.opencode;
    settings = {
      default_agent = "plan";
      plugins = [
        "@simonwjackson/opencode-direnv"
        "@franlol/opencode-md-table-formatter@latest"
        "opencode-mermaid-renderer@latest"
      ];
      mcp = {
        servers =
          {
            codegraph = {
              type = "local";
              command = ["codegraph" "serve" "--mcp"];
            };
          }
          // lib.optionalAttrs hasRadar {
            radar = {
              type = "remote";
              url = "http://localhost:9280/mcp";
            };
          };
      };
      permissions = [
        {
          action = "shell";
          resource = "rm *";
          effect = "ask";
        }
        {
          action = "external_directory";
          resource = "${config.xdg.configHome}/opencode/*";
          effect = "allow";
        }
        {
          action = "external_directory";
          resource = "/tmp/*";
          effect = "allow";
        }
        {
          action = "external_directory";
          resource = "${config.home.homeDirectory}/code/*";
          effect = "allow";
        }
      ];
    };
  };

  home.sessionVariables.OPENCODE_CONFIG = "$HOME/.config/opencode/overrides.json";

  home.persistence."/persist".directories = [
    ".local/share/opencode"
    ".config/opencode"
    ".agents"
  ];
}
