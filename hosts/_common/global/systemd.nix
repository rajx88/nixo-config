{pkgs, ...}: {
  systemd = {
    targets = {
      sleep = {
        enable = true;
      };
      suspend = {
        enable = true;
      };
      hibernate = {
        enable = false;
      };
      # hybrid-sleep is not set, so it remains disabled by default
    };
  };
}
