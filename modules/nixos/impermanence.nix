{
  config,
  inputs,
  lib,
  outputs,
  pkgs,
  ...
}: let
  cfg_impermanence = config.host.filesystem.impermanence;
  cfg_encrypt = config.host.filesystem.encryption;
in
  with lib; {
    imports = [
      inputs.impermanence.nixosModules.impermanence
    ];

    options = {
      host.filesystem.impermanence = {
        enable = mkOption {
          default = false;
          type = with types; bool;
          description = "Wipe root filesystem and restore blank root BTRFS subvolume on boot. Also known as 'Erasing your darlings'";
        };
        root-subvol = mkOption {
          type = types.str;
          default = "root";
          description = "Root subvolume to wipe on boot";
        };
        blank-root-subvol = mkOption {
          type = types.str;
          default = "root-blank";
          description = "Blank root subvolume to restore on boot";
        };
        directories = mkOption {
          type = types.listOf types.anything;
          default = [];
          description = "Directories that should be persisted between reboots";
        };
        files = mkOption {
          type = types.listOf types.anything;
          default = [];
          description = "Files that should be persisted between reboots";
        };
      };
    };

    config = lib.mkMerge [
      {
        boot.initrd = lib.mkMerge [
          (lib.mkIf (cfg_impermanence.enable && cfg_encrypt.enable) {
            systemd = {
              enable = true;
              services.rollback = {
                description = "Rollback BTRFS root subvolume to a pristine state";
                wantedBy = [
                  "initrd.target"
                ];
                after = [
                  "systemd-cryptsetup@${cfg_encrypt.encrypted-partition}.service"
                ];
                before = [
                  "sysroot.mount"
                ];
                unitConfig.DefaultDependencies = "no";
                serviceConfig.Type = "oneshot";
                script = ''
                  mkdir -p /mnt
                  mount -o subvol=/ /dev/mapper/${cfg_encrypt.encrypted-partition} /mnt
                  btrfs subvolume list -o /mnt/${cfg_impermanence.root-subvol} | cut -f9 -d' ' |
                  while read subvolume; do
                    echo "Deleting /$subvolume subvolume"
                    btrfs subvolume delete "/mnt/$subvolume"
                  done &&
                  echo "Deleting /${cfg_impermanence.root-subvol} subvolume" &&
                  btrfs subvolume delete /mnt/${cfg_impermanence.root-subvol}
                  echo "Restoring blank /${cfg_impermanence.root-subvol} subvolume"
                  btrfs subvolume snapshot /mnt/${cfg_impermanence.blank-root-subvol} /mnt/${cfg_impermanence.root-subvol}
                  # mkdir -p /mnt/${cfg_impermanence.root-subvol}/mnt
                  umount /mnt
                '';
              };
            };
          })
        ];

        environment = mkIf cfg_impermanence.enable {
          systemPackages = let
            # Running this will show what changed during boot to potentially use for persisting
            # read the canonical script from the repository root
            impermanence-fsdiff = pkgs.writeShellScriptBin "impermanence-fsdiff" (builtins.readFile ../../scripts/impermanence-fsdiff.sh);
          in
            with pkgs; [
              impermanence-fsdiff
            ];

          persistence."/persist" = {
            # hideMounts = true;
            directories =
              [
                "/var/lib/systemd"
                "/var/lib/nixos"
                # "/var/log"
                "/srv"
              ]
              ++ cfg_impermanence.directories;
            files =
              [
                "/etc/machine-id"
              ]
              ++ cfg_impermanence.files;
          };
        };

        fileSystems = mkIf cfg_impermanence.enable {
          "/persist" = {
            options = ["subvol=persist" "compress=zstd" "noatime"];
            neededForBoot = true;
          };
        };

        host.filesystem.impermanence.directories = mkIf ((config.host.filesystem.impermanence.enable) && (config.networking.networkmanager.enable)) [
          "/etc/NetworkManager" # NetworkManager TODO Potentially should be its own module but at least it is limited in this config
          "/var/lib/NetworkManager" # NetworkManager
        ];

        services = mkIf cfg_impermanence.enable {
          # btrbk = {
          #   instances."btrbak" = {
          #     settings = {
          #       volume."/persist" = {
          #         snapshot_create = "always";
          #         subvolume = ".";
          #         snapshot_dir = ".snapshots";
          #       };
          #     };
          #   };
          # };
        };

        security = mkIf cfg_impermanence.enable {
          sudo.extraConfig = ''
            Defaults lecture = never
          '';
        };

        # programs.fuse.userAllowOther = mkIf (config.host.filesystem.impermanence.enable) true;

        system.activationScripts = mkIf (config.host.filesystem.impermanence.enable) {
          persistent-dirs.text = let
            mkHomePersist = user:
              lib.optionalString user.createHome ''
                mkdir -p /persist/${user.home}
                chown ${user.name}:${user.group} /persist/${user.home}
                chmod ${user.homeMode} /persist/${user.home}
              '';
            users = lib.attrValues config.users.users;
          in
            lib.concatLines (map mkHomePersist users);
        };
      }
    ];
  }
