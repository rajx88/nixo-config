{
  pkgs,
  lib,
  ...
}:
{
  # hardware.enableAllFirmware = true;
  services.pulseaudio.enable = lib.mkForce false;

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # jack.enable is intentionally off: it is deprecated in nixpkgs because it
    # exports a global LD_LIBRARY_PATH (impure), and nothing here runs a JACK
    # client. If that changes, launch the app through `pw-jack` from
    # pkgs.pipewire.jack instead of re-enabling this.

    wireplumber = {
      enable = true;
      package = pkgs.wireplumber;
    };
  };
}
