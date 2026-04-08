{
  pkgs,
  inputs,
  config,
  ...
}: let
  ocd =
    pkgs.writeShellScriptBin "ocd"
    (builtins.readFile ../../../../scripts/opencode.sh);

  # Override the upstream opencode package to fix node_modules hash mismatch on x86_64-linux
  opencodePkgs = inputs.opencode-flake.packages.${pkgs.stdenv.hostPlatform.system};
  opencodePackage = opencodePkgs.opencode.override {
    node_modules = opencodePkgs.opencode.node_modules.override {
      hash = "sha256-85wpU1oCWbthPleNIOj5d5AOuuYZ6rM7gMLZR6YJ2WU=";
    };
  };
in {
  programs.opencode = {
    enable = true;
    package = opencodePackage;
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
