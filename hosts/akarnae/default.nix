{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  imports = [
    inputs.hardware.nixosModules.common-cpu-intel-cpu-only
    inputs.hardware.nixosModules.common-gpu-nvidia
    inputs.hardware.nixosModules.common-pc-ssd

    ./hardware-configuration.nix
    ./disko-config.nix

    ../_common/global
    ../_common/users/rajkoh

    ../_common/optional/systemd-boot.nix
    # ../_common/optional/gnome.nix
    ../_common/optional/pipewire.nix
  ];

  # environment = {
  #   # needed for completion for system packages
  #   pathsToLink = ["/share/zsh"];
  # };

  networking = {
    hostName = "akarnae";
    useDHCP = lib.mkForce true;
  };

  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_zen;
  };

  # boot.loader.systemd-boot = {
  #   extraEntries = {
  #     "nvidia-drm.modeset=1"
  #   }
  # };

  programs = {
    # adb.enable = true;
    dconf.enable = true;
    # kdeconnect.enable = true;
  };

  services.hardware.openrgb.enable = true;

  hardware = {
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };

    nvidia = {
      prime.offload.enable = false;
      # Modesetting is required.
      modesetting.enable = true;

      # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
      powerManagement.enable = false;
      # Fine-grained power management. Turns off GPU when not in use.
      # Experimental and only works on modern Nvidia GPUs (Turing or newer).
      powerManagement.finegrained = false;

      # Use the NVidia open source kernel module (not to be confused with the
      # independent third-party "nouveau" open source driver).
      # Support is limited to the Turing and later architectures. Full list of
      # supported GPUs is at:
      # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
      # Only available from driver 515.43.04+
      # Currently alpha-quality/buggy, so false is currently the recommended setting.
      open = false;

      # Enable the Nvidia settings menu,
      # accessible via `nvidia-settings`.
      nvidiaSettings = true;

      # Optionally, you may need to select the appropriate driver version for your specific GPU.
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
  };

  # DO NOT TOUCH BEFORE GOOGLING IT.
  system.stateVersion = "23.11"; # Did you read the comment?
}
