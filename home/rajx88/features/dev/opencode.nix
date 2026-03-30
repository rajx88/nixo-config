{
  pkgs,
  inputs,
  config,
  ...
}: let
  ocd =
    pkgs.writeShellScriptBin "ocd"
    (builtins.readFile ../../../../scripts/opencode.sh);
in {
  programs.opencode = {
    enable = true;
    package = inputs.opencode-flake.packages.${pkgs.stdenv.hostPlatform.system}.default;
    settings = {
      default_agent = "plan";
      plugin = ["@tarquinen/opencode-dcp@latest"];
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
