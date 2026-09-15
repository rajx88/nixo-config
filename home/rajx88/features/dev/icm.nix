{
  pkgs,
  lib,
  config,
  ...
}: {
  # Enabled by default: importing this module is what turns icm (and its
  # maintenance timer) on. Set `programs.icm.enable = false` to opt out.
  options.programs.icm.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Whether to enable ICM persistent memory.";
  };

  config = lib.mkIf config.programs.icm.enable {
    home.packages = [pkgs.icm];

    home.persistence."/persist".directories = [
      ".local/share/icm"
    ];
  };
}
