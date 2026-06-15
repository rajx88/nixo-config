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
    ../../tmpl/efi-luks-btrfs-impermanence-swap.nix

    ../_common/global
    ../_common/users/rajx88

    ../_common/optional/zsa.nix
    ../_common/optional/systemd-boot.nix
    ../_common/optional/ly.nix
    ../_common/optional/mango.nix

    ../_common/optional/pipewire.nix
    ../_common/optional/net-debug.nix
  ];

  host.filesystem = {
    encryption.enable = true;
    impermanence.enable = true;
  };

  networking = {
    networkmanager.enable = true;
    hostName = "akarnae";
    useDHCP = lib.mkForce true;
  };

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_drm" "nvidia_uvm" ];
    kernelParams = [ "nvidia.NVreg_PreserveVideoMemoryAllocations=1" ];
  };

  nixpkgs.config.nvidia.acceptLicense = true;

  programs = {
    dconf.enable = true;
  };

  services.hardware.openrgb.enable = true;

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
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

      # legacy_580 (580.159.04) required for GTX 1080 Ti (Pascal) — 595+ dropped support
      package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
    };
  };

  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    WLR_DRM_NO_ATOMIC = "1";
    LIBVA_DRIVER_NAME = "nvidia";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    __GL_VRR_ALLOWED = "1";
  };

  # DO NOT TOUCH BEFORE GOOGLING IT.
  system.stateVersion = "23.11"; # Did you read the comment?
}
