{
  pkgs,
  inputs,
  config,
  ...
}: let
  ocd =
    pkgs.writeShellScriptBin "ocd"
    (builtins.readFile ../../../../scripts/opencode.sh);

  opencodePkgs = inputs.opencode-flake.packages.${pkgs.stdenv.hostPlatform.system};
in {
  programs.opencode = {
    enable = true;
    package = opencodePkgs.opencode;
    settings = {
      default_agent = "plan";
      plugin = [
        "@tarquinen/opencode-dcp@latest"
        "@simonwjackson/opencode-direnv"
        "superpowers@git+https://github.com/obra/superpowers.git"
      ];
      permission = {
        bash = {
          "rm *" = "ask";
        };
        external_directory = {
          "${config.xdg.configHome}/opencode/**" = "allow";
          "/tmp/**" = "allow";
        };
      };
    };
  };

  home.packages = [ocd];

  home.sessionVariables.OPENCODE_CONFIG = "$HOME/.config/opencode/overrides.json";

  home.persistence."/persist".directories = [
    ".local/share/opencode"
    ".config/opencode"
  ];
}
