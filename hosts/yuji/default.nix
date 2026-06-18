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
    inputs.nix-barracudavpn.nixosModules.proxy-certs

    ./hardware-configuration.nix
    ../../tmpl/efi-luks-btrfs-impermanence.nix

    ../_common/global
    ../_common/users/rajx88

    ../_common/optional/zsa.nix
    ../_common/optional/systemd-boot.nix
    ../_common/optional/ly.nix
    ../_common/optional/mango.nix

    ../_common/optional/pipewire.nix
    ../_common/optional/laptop.nix
    ../_common/optional/openvpn.nix
    ../_common/optional/net-debug.nix
    ../_common/optional/wireguard.nix
    # ../_common/optional/hindsight.nix
  ];

  nixpkgs.config.nvidia.acceptLicense = true;

  host.filesystem = {
    encryption.enable = true;
    impermanence.enable = true;
  };

  host.backup = {
    enable = true;
    rclone-remote = "gdrive:yuji";
  };

  networking = {
    networkmanager.enable = true;
    hostName = "yuji";
    useDHCP = lib.mkForce false; # NM handles DHCP; dhcpcd conflicts w/ resolved DNS
  };

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_drm" "nvidia_uvm" ];
    kernelParams  = [ "nvidia.NVreg_PreserveVideoMemoryAllocations=1" ];
    blacklistedKernelModules = [ "nouveau" ];
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
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };

    nvidia = {
      prime.offload.enable = false;   # no PRIME offload — Intel drives all displays
      modesetting.enable        = true;
      powerManagement.enable    = false;
      powerManagement.finegrained = false;
      open            = true;         # required for Blackwell (GB207 / sm_120)
      nvidiaSettings  = true;
      package = config.boot.kernelPackages.nvidiaPackages.latest;
    };

    nvidia-container-toolkit.enable = true;
  };

  virtualisation.docker.enableNvidia = true;

  # DO NOT TOUCH BEFORE GOOGLING IT.
  system.stateVersion = "23.11"; # Did you read the comment?
}
