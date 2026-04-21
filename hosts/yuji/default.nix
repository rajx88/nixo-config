{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  imports = [
    inputs.hardware.nixosModules.common-cpu-intel
    # inputs.hardware.nixosModules.common-gpu-nvidia  # commented out — using Intel iGPU only
    inputs.hardware.nixosModules.common-pc-ssd

    inputs.nix-barracudavpn.nixosModules.barracudavpn
    inputs.nix-barracudavpn.nixosModules.proxy-certs

    ./hardware-configuration.nix
    ../../tmpl/efi-luks-btrfs-impermanence.nix

    ../_common/global
    ../_common/users/rajx88

    ../_common/optional/zsa.nix
    ../_common/optional/systemd-boot.nix
    ../_common/optional/greetd.nix

    ../_common/optional/pipewire.nix
    ../_common/optional/laptop.nix
    ../_common/optional/openvpn.nix
  ];

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
    # kernelPackages = pkgs.linuxPackages_latest;
    # kernelPackages = pkgs.linuxPackages;
    kernelPackages = pkgs.linuxKernel.packages.linux_zen;
    # kernelPackages = pkgs.linuxPackages_6_17;
    # kernelParams = ["nvidia.NVreg_PreserveVideoMemoryAllocations=1"];
    # kernelParams = ["nvidia-drm.modeset=1"];
    # Uncomment the desired line below to switch between Intel-only (NVIDIA disabled) and default (NVIDIA enabled):
    # Intel-only (NVIDIA disabled):
    blacklistedKernelModules = [
      "nouveau"
      # Uncomment below when re-enabling nvidia drivers
      # "nvidia"
      # "nvidia_drm"
      # "nvidia_modeset"
      # "nvidia_uvm"
    ];
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

  proxy.certs.enable = true;

  services.hardware.openrgb.enable = true;

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };

    # nvidia — commented out, using Intel iGPU only. Uncomment to re-enable.
    # nvidia = {
    #   modesetting.enable = true;
    #   powerManagement.enable = false;
    #   powerManagement.finegrained = false;
    #   open = true;
    #   nvidiaSettings = true;
    #   prime = {
    #     offload.enable = false;
    #     # offload.enableOffloadCmd = true;
    #     sync.enable = true;
    #     intelBusId = "PCI:0:2:0";
    #     nvidiaBusId = "PCI:1:0:0";
    #   };
    #   package = config.boot.kernelPackages.nvidiaPackages.latest;
    # };
  };

  # DO NOT TOUCH BEFORE GOOGLING IT.
  system.stateVersion = "23.11"; # Did you read the comment?
}
