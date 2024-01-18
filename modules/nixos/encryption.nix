{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.host.filesystem.encryption;
in
  with lib; {
    options = {
      host.filesystem.encryption = {
        enable = mkOption {
          default = false;
          type = with types; bool;
          description = "Encrypt Filesystem using LUKS";
        };
        encrypted-partition = mkOption {
          type = types.str;
          default = "crypted";
          description = "Encrypted LUKS container to mount";
        };
      };
    };
  }
