{pkgs, inputs, ...}: let
  ocd =
    pkgs.writeShellScriptBin "ocd"
    (builtins.readFile ../../../../scripts/opencode.sh);
in {
  programs.opencode = {
    enable = true;
    package = inputs.opencode-flake.packages.${pkgs.system}.default;
  };

  home.packages = [ocd];

  home.persistence."/persist".directories = [
    ".local/share/opencode"
    ".config/opencode"
  ];
}
