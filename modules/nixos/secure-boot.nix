{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  cfg = config.host.secureBoot;
in {
  imports = [
    inputs.lanzaboote.nixosModules.lanzaboote
  ];

  options.host.secureBoot = {
    enable = lib.mkEnableOption "UEFI Secure Boot via lanzaboote";

    configurationLimit = lib.mkOption {
      type = lib.types.int;
      default = 10;
      description = "Maximum number of NixOS generations kept on the EFI system partition.";
    };
  };

  config = lib.mkMerge [
    # Persist the sbctl PKI bundle so the signing keys survive the impermanence wipe.
    # This is done unconditionally (not only when Secure Boot is enabled) so the keys
    # can be generated after a reboot with the bind mount already active, *before*
    # lanzaboote starts signing.
    (lib.mkIf config.host.filesystem.impermanence.enable {
      host.filesystem.impermanence.directories = ["/var/lib/sbctl"];
    })

    (lib.mkIf cfg.enable {
      boot.loader.systemd-boot.enable = lib.mkForce false;
      boot.loader.efi.canTouchEfiVariables = true;

      boot.lanzaboote = {
        enable = true;
        pkiBundle = "/var/lib/sbctl";
        configurationLimit = cfg.configurationLimit;
      };

      # For debugging and troubleshooting Secure Boot.
      environment.systemPackages = [pkgs.sbctl];
    })
  ];
}
