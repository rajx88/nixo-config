{pkgs, inputs, ...}: let
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
    };
  };

  home.packages = [ocd];

  home.sessionVariables.OPENCODE_CONFIG = "$HOME/.config/opencode/overrides.json";

  home.persistence."/persist".directories = [
    ".local/share/opencode"
    ".config/opencode"
  ];
}
