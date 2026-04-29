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
        # "@tarquinen/opencode-dcp@latest"
        "@simonwjackson/opencode-direnv"
        "superpowers@git+https://github.com/obra/superpowers.git"
        "@franlol/opencode-md-table-formatter@latest"
        "opencode-mermaid-renderer@latest"
      ];
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

  home.packages = [ocd];

  home.file.".local/completions/_ocd".text = ''
    #compdef ocd

    _ocd() {
      _arguments \
        '*-d[Mount directory into container]:directory:_directories' \
        '-h[Show help]' \
        '*::opencode args:_default'
    }

    _ocd "$@"
  '';

  home.sessionVariables.OPENCODE_CONFIG = "$HOME/.config/opencode/overrides.json";

  home.persistence."/persist".directories = [
    ".local/share/opencode"
    ".config/opencode"
    ".agents"
  ];
}
