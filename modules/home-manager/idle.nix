{ lib, ... }:
{
  options.idle = {
    lockTimeout = lib.mkOption {
      type = lib.types.ints.positive;
      default = 5 * 60;
      description = "Seconds of inactivity before the session is locked.";
      example = 15 * 60;
    };

    lockTimeoutHome = lib.mkOption {
      type = lib.types.nullOr lib.types.ints.positive;
      default = null;
      description = ''
        Lock timeout to use when the active monitor profile is one of
        homeProfiles. `null` means lockTimeout applies everywhere.
      '';
      example = 30 * 60;
    };

    homeProfiles = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "home" ];
      description = ''
        Monitor profile names that count as "home" for lockTimeoutHome.
        Read at timeout time from the active mango profile.
      '';
    };

    dpmsTimeout = lib.mkOption {
      type = lib.types.ints.positive;
      default = 5 * 60;
      description = ''
        Seconds of inactivity before all outputs are powered off. Absolute idle
        time, independent of lockTimeout: it may fire before or after the lock.
      '';
      example = 5 * 60;
    };
  };
}
