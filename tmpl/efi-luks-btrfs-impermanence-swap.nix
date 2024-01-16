{disks ? ["/dev/nvme0n1"], ...}: let
  rawdisk = builtins.elemAt disks 0;
in {
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "${rawdisk}";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              label = "EFI";
              size = "1024M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [
                  "defaults"
                ];
              };
            };
            encryptedSwap = {
              label = "swap";
              size = "48G";
              content = {
                type = "swap";
                randomEncryption = true;
              };
            };
            luks = {
              label = "crypted";
              size = "100%";
              content = {
                type = "luks";
                name = "crypted";
                # disable settings.keyFile and passwordFile if you want to use interactive password entry
                # be sure there is no trailing newline, for example use `echo -n "password" > /tmp/secret.key`
                passwordFile = "/tmp/secret.key"; # Interactive
                # or file based
                settings = {
                  allowDiscards = true;
                  #  keyFile = "/tmp/secret.key";
                };
                # additionalKeyFiles = [ "/tmp/additionalSecret.key" ];
                content = {
                  type = "btrfs";
                  extraArgs = ["-f"];
                  subvolumes = {
                    "/root" = {
                      mountpoint = "/";
                      mountOptions = ["compress=zstd" "noatime"];
                    };
                    "/root-blank" = {};
                    "/nix" = {
                      mountpoint = "/nix";
                      mountOptions = ["compress=zstd" "noatime"];
                    };
                    "/persist" = {
                      mountpoint = "/persist";
                      mountOptions = ["compress=zstd" "noatime"];
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
