{
  pkgs,
  config,
  ...
}: let
  ocd =
    pkgs.writeShellScriptBin "ocd"
    (builtins.readFile ../../../../scripts/opencode.sh);
in {
  programs.opencode = {
    enable = true;
    package = pkgs.opencode;
    settings = {
      default_agent = "plan";
      plugin = [
        "@simonwjackson/opencode-direnv"
        "@franlol/opencode-md-table-formatter@latest"
        "opencode-mermaid-renderer@latest"
      ];
      mcp = {
        codegraph = {
          type = "local";
          command = ["codegraph" "serve" "--mcp"];
          enabled = true;
        };
      };
      permission = {
        bash = {
          "rm *" = "ask";
        };
        external_directory = {
          "${config.xdg.configHome}/opencode/**" = "allow";
          "/tmp/**" = "allow";
          "${config.home.homeDirectory}/code/**" = "allow";
        };
      };
    };
  };

  home.sessionVariables.OPENCODE_CONFIG = "$HOME/.config/opencode/overrides.json";

  home.persistence."/persist".directories = [
    ".local/share/opencode"
    ".config/opencode"
    ".agents"
  ];
}
