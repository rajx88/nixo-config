{
  disko.devices = {
    disk = {
      vdb = {
        type = "disk";
        device = "/dev/vdb";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "512M";
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
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "crypted";
                # disable settings.keyFile if you want to use interactive password entry
                #passwordFile = "/tmp/secret.key"; # Interactive
                #settings = {
                #  allowDiscards = true;
                #  keyFile = "/tmp/secret.key";
                #};
                additionalKeyFiles = [ "/tmp/additionalSecret.key" ];
                content = {
                  type = "btrfs";
                  # BTRFS partition is not mounted as it doesn't set a mountpoint explicitly
                  subvolumes = {
                    # This subvolume will not be mounted
                    "SYSTEM" = { };
                    # mounted as "/"
                    "SYSTEM/rootfs" = {
                      mountpoint = "/";
                    };
                    # mounted as "/nix"
                    "SYSTEM/nix" = {
                      mountOptions = [ "compress=zstd" "noatime" ];
                      mountpoint = "/nix";
                    };
                    # This subvolume will not be mounted
                    "DATA" = { };
                    # mounted as "/home"
                    "DATA/home" = {
                      mountOptions = [ "compress=zstd" ];
                      mountpoint = "/home";
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
