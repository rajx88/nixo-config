{ config, lib, pkgs, ... }:
let
  cfg = config.programs.worktrunk;
in {
  options.programs.worktrunk = {
    enable = lib.mkEnableOption "Worktrunk git worktree manager";
    shellIntegration = {
      zsh = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Worktrunk shell integration for Zsh.";
      };
      bash = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Worktrunk shell integration for Bash.";
      };
      fish = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Worktrunk shell integration for Fish.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.worktrunk ];

    programs.zsh.initContent = lib.mkIf cfg.shellIntegration.zsh ''
      eval "$(wt config shell init zsh)"
    '';
    programs.bash.initExtra = lib.mkIf cfg.shellIntegration.bash ''
      eval "$(wt config shell init bash)"
    '';
    programs.fish.shellInit = lib.mkIf cfg.shellIntegration.fish ''
      wt config shell init fish | source
    '';
  };
}
