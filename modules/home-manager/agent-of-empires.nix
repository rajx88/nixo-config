{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.agent-of-empires;
  tomlFormat = pkgs.formats.toml {};
  configFile = tomlFormat.generate "aoe-config" cfg.config;
in {
  options.programs.agent-of-empires = {
    enable = lib.mkEnableOption "Agent of Empires terminal session manager for AI coding agents";
    shellIntegration = {
      zsh = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable AoE shell completions for Zsh.";
      };
      bash = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable AoE shell completions for Bash.";
      };
      fish = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable AoE shell completions for Fish.";
      };
    };
    config = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
      default = {};
      description = "Declarative AoE config (generates ~/.config/agent-of-empires/config.toml).";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [pkgs.agent-of-empires];

    # Use activation script instead of xdg.configFile to produce a mutable
    # copy.  aoe needs to write back to config.toml at runtime (e.g. color
    # codes, schema migrations), which fails when the file is a read-only
    # symlink into the Nix store.
    home.activation.aoeConfig = lib.mkIf (cfg.config != {}) (
      lib.hm.dag.entryAfter ["writeBoundary"] ''
        aoe_dir="${config.xdg.configHome}/agent-of-empires"
        $DRY_RUN_CMD mkdir -p "$aoe_dir"
        $DRY_RUN_CMD rm -f "$aoe_dir/config.toml"
        $DRY_RUN_CMD cp ${configFile} "$aoe_dir/config.toml"
        $DRY_RUN_CMD chmod u+w "$aoe_dir/config.toml"
      ''
    );

    programs.zsh.initContent = lib.mkIf cfg.shellIntegration.zsh ''
      eval "$(aoe completion zsh)"
    '';
    programs.bash.initExtra = lib.mkIf cfg.shellIntegration.bash ''
      eval "$(aoe completion bash)"
    '';
    programs.fish.shellInit = lib.mkIf cfg.shellIntegration.fish ''
      aoe completion fish | source
    '';
  };
}
