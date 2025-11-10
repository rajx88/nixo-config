{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  imports = [
    inputs.hardware.nixosModules.common-cpu-intel
    inputs.hardware.nixosModules.common-gpu-nvidia
    inputs.hardware.nixosModules.common-pc-ssd

    inputs.nix-barracudavpn.nixosModules.barracudavpn
    inputs.nix-barracudavpn.nixosModules.proxy

    ./hardware-configuration.nix
    ../../tmpl/efi-luks-btrfs-impermanence.nix

    ../_common/global
    ../_common/users/rajx88

    ../_common/optional/zsa.nix
    ../_common/optional/systemd-boot.nix
    ../_common/optional/greetd.nix

    ../_common/optional/pipewire.nix
  ];

  programs.barracudavpn.package = inputs.nix-barracudavpn.packages.${pkgs.stdenv.hostPlatform.system}.barracudavpn;

  services.proxy.pac = {
    enable = true;
    url = inputs.nix-barracudavpn.proxyConfig.pacUrl;
  };

  host.filesystem = {
    encryption.enable = true;
    impermanence.enable = true;
  };

  networking = {
    networkmanager.enable = true;
    hostName = "yuji";
    useDHCP = lib.mkForce true;
  };

  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_zen;
    # kernelParams = ["nvidia.NVreg_PreserveVideoMemoryAllocations=1"];
    # kernelParams = ["nvidia-drm.modeset=1"];
    # Belt-and-suspenders: make sure nouveau never grabs the GPU
    blacklistedKernelModules = ["nouveau"];
  };

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50; # allow up to RAM/2
    memoryMax = 8 * 1024 * 1024 * 1024; # hard cap at 8 GiB (BYTES!)
    priority = 100;
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
    barracudavpn.enable = true;
  };

  services.hardware.openrgb.enable = true;

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };

    nvidia = {
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
      open = true;

      # Enable the Nvidia settings menu,
      # accessible via `nvidia-settings`.
      nvidiaSettings = true;

      prime = {
        offload.enable = false;
        # offload.enableOffloadCmd = true;
        sync.enable = true;
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
      };

      # Optionally, you may need to select the appropriate driver version for your specific GPU.
      package = config.boot.kernelPackages.nvidiaPackages.latest;
    };
  };

  # DO NOT TOUCH BEFORE GOOGLING IT.
  system.stateVersion = "23.11"; # Did you read the comment?
}
