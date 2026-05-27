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

    functions = {
      fish_greeting = "# disabled";
    };

    interactiveShellInit = ''
      # Aura theme colors (universal so they persist)
      if not set -q __fish_aura_applied
        set -U fish_color_normal edecee
        set -U fish_color_command 61ffca
        set -U fish_color_keyword f694ff
        set -U fish_color_quote ffca85
        set -U fish_color_redirection f694ff
        set -U fish_color_end 61ffca
        set -U fish_color_error ff6767
        set -U fish_color_param a277ff
        set -U fish_color_comment 6d6d6d
        set -U fish_color_operator a277ff
        set -U fish_color_escape f694ff
        set -U fish_color_autosuggestion 6d6d6d
        set -U fish_color_valid_path --underline
        set -U fish_color_search_match --background=29263c
        set -U fish_color_selection --background=29263c
        set -U __fish_aura_applied 1
      end

      # cdpath
      set -gx CDPATH . ~ ~/code ~/code/prvt ~/code/work /opt/hawaii/workspace

      # session variables
      set -gx MINIKUBE_HOME $XDG_DATA_HOME/minikube

      # local bin
      fish_add_path -m $HOME/.local/bin
    '';
  };
}
