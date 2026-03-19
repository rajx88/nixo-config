{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.agent-of-empires;
  tomlFormat = pkgs.formats.toml {};
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
    xdg.configFile = lib.mkIf (cfg.config != {}) {
      "agent-of-empires/config.toml" = {
        source = tomlFormat.generate "aoe-config" cfg.config;
      };
    };
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
