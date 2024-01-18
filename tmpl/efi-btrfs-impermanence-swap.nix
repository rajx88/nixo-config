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
            root = {
              label = "rootfs";
              name = "btrfs";
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = ["-f"];
                subvolumes = {
                  "/root" = {
                    mountpoint = "/";
                    mountOptions = ["compress=zstd" "noatime"];
                  };
                  "/root-blank" = {
                    mountOptions = ["compress=zstd" "noatime"];
                  };
                  "/home" = {
                    mountpoint = "/home";
                    mountOptions = ["compress=zstd" "noatime"];
                  };
                  "/home/snapshots" = {
                    mountpoint = "/home/.snapshots";
                    mountOptions = ["compress=zstd" "noatime"];
                  };
                  "/nix" = {
                    mountpoint = "/nix";
                    mountOptions = ["compress=zstd" "noatime"];
                  };
                  "/persist" = {
                    mountpoint = "/persist";
                    mountOptions = ["compress=zstd" "noatime"];
                  };
                  "/persist/snapshots" = {
                    mountpoint = "/persist/.snapshots";
                    mountOptions = ["compress=zstd" "noatime"];
                  };
                  "/log" = {
                    mountpoint = "/var/log";
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
}
