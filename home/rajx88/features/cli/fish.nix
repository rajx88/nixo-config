{
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf;
  hasPackage = pname: lib.any (p: p ? pname && p.pname == pname) config.home.packages;
  hasEza = hasPackage "eza";
  hasLazyGit = hasPackage "lazygit";
  hasFastFetch = hasPackage "fastfetch";
  hasNeovim = config.programs.neovim.enable;
in {
  home.persistence."/persist".directories = [
    ".config/fish"
    ".local/share/fish"
  ];

  programs.fish = {
    enable = true;

    shellAbbrs = {
      jqless = "jq -C | less -r";

      # nix
      n = "nix";
      nd = "nix develop -c $SHELL";
      ns = "nix shell";
      nsn = "nix shell nixpkgs#";
      nb = "nix build";
      nbn = "nix build nixpkgs#";
      nf = "nix flake";

      # tools
      lg = mkIf hasLazyGit "lazygit";
      ff = mkIf hasFastFetch "fastfetch";

      # gradle
      gw = "./gradlew";
      gwp = "./gradlew --no-configuration-cache clean publishToMavenLocal";

      # worktrunk
      wso = "wt switch --create --execute=opencode";
    };

    shellAliases = {
      ls = mkIf hasEza "eza --icons";
      ll = mkIf hasEza "eza --icons -abghHliS";
      tree = mkIf hasEza "eza --icons --tree -abghHliS";
      grep = "grep --color";
    };

    interactiveShellInit = ''
      # cdpath
      set -gx CDPATH . ~ ~/code ~/code/prvt ~/code/work /opt/hawaii/workspace

      # session variables
      set -gx MINIKUBE_HOME $XDG_DATA_HOME/minikube

      # local bin
      fish_add_path -m $HOME/.local/bin
    '';
  };
}
