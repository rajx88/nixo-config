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

                  mkdir /tmp -p
                  MNTPOINT=$(mktemp -d)
                  (

                    mount -t btrfs -o subvol=/ /dev/mapper/${cfg_encrypt.encrypted-partition} "$MNTPOINT"
                    trap 'umount "$MNTPOINT"' EXIT

                    echo "Creating needed directories"
                    mkdir -p "$MNTPOINT"/persist/var/{log,lib/{nixos,systemd}}

                    echo "Cleaning root subvolume"
                    btrfs subvolume list -o "$MNTPOINT/${cfg_impermanence.root-subvol}" | cut -f9 -d' ' |
                    while read subvolume; do
                      echo "Deleting /$subvolume subvolume"
                      btrfs subvolume delete "$MNTPOINT/$subvolume"
                    done &&
                    echo "Deleting /${cfg_impermanence.root-subvol} subvolume" &&
                    btrfs subvolume delete "$MNTPOINT/${cfg_impermanence.root-subvol}"

                    echo "Restoring blank /${cfg_impermanence.root-subvol} subvolume"
                    btrfs subvolume snapshot "$MNTPOINT/${cfg_impermanence.blank-root-subvol}" "$MNTPOINT/${cfg_impermanence.root-subvol}"

                    umount "$MNTPOINT"
                  )
                '';
              };
            };
          })
        ];

        environment = mkIf cfg_impermanence.enable {
          systemPackages = let
            # Running this will show what changed during boot to potentially use for persisting
            impermanence-fsdiff = pkgs.writeShellScriptBin "impermanence-fsdiff" ''
              _mount_drive=''${1:-"$(mount | grep '.* on / type btrfs' | awk '{ print $1}')"}
              _tmp_root=$(mktemp -d)
              mkdir -p "$_tmp_root"
              sudo mount -o subvol=/ "$_mount_drive" "$_tmp_root" > /dev/null 2>&1

              set -euo pipefail

              OLD_TRANSID=$(sudo btrfs subvolume find-new $_tmp_root/root-blank 9999999)
              OLD_TRANSID=''${OLD_TRANSID#transid marker was }

              sudo btrfs subvolume find-new "$_tmp_root/${cfg_impermanence.root-subvol}" "$OLD_TRANSID" | sed '$d' | cut -f17- -d' ' | sort | uniq |
              while read path; do
                path="/$path"
                 if [ -L "$path" ]; then
                    : # The path is a symbolic link, so is probably handled by NixOS already
                  elif [ -d "$path" ]; then
                    : # The path is a directory, ignore
                  else
                    echo "$path"
                  fi
                done
                sudo umount "$_tmp_root"
                rm -rf "$_tmp_root"
            '';
          in
            with pkgs; [
              impermanence-fsdiff
            ];

          persistence."/persist" = {
            hideMounts = true;
            directories =
              [
                "/var/lib/systemd"
                "/var/lib/nixos"
                # "/var/log"
                "/srv"
              ]
              ++ cfg_impermanence.directories;
            files = cfg_impermanence.files;
          };
        };

        fileSystems = mkIf cfg_impermanence.enable {
          "/persist" = {
            options = ["subvol=persist/active" "compress=zstd" "noatime"];
            neededForBoot = true;
          };
          "/persist/.snapshots" = {
            options = ["subvol=persist/snapshots" "compress=zstd" "noatime"];
          };
        };

        host.filesystem.impermanence.directories = mkIf ((config.host.filesystem.impermanence.enable) && (config.networking.networkmanager.enable)) [
          "/etc/NetworkManager" # NetworkManager TODO Potentially should be its own module but at least it is limited in this config
          "/var/lib/NetworkManager" # NetworkManager
        ];

        services = mkIf cfg_impermanence.enable {
          btrbk = {
            instances."btrbak" = {
              settings = {
                volume."/persist" = {
                  snapshot_create = "always";
                  subvolume = ".";
                  snapshot_dir = ".snapshots";
                };
              };
            };
          };
        };

        security = mkIf cfg_impermanence.enable {
          sudo.extraConfig = ''
            Defaults lecture = never
          '';
        };

        programs.fuse.userAllowOther = mkIf (config.host.filesystem.impermanence.enable) true;

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
