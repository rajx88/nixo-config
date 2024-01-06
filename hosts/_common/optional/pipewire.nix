{
  pkgs,
  lib,
  ...
}: {
  # hardware.enableAllFirmware = true;
  hardware.pulseaudio.enable = lib.mkForce false;
  sound.enable = false;

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;

    wireplumber = {
      enable = true;
      package = pkgs.wireplumber;
    };
  };
}
