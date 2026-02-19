{
  pkgs,
  ...
}: let
  ocd = pkgs.writeShellScriptBin "ocd"
    (builtins.readFile ../../../../scripts/opencode.sh);
in {
  programs.opencode = {
    enable = true;
  };

  home.packages = [ocd];

  home.persistence."/persist".directories = [
    ".local/share/opencode"
    ".config/opencode"
  ];
}
