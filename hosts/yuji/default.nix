{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  imports = [
    inputs.hardware.nixosModules.common-cpu-intel
    inputs.hardware.nixosModules.common-gpu-nvidia
    inputs.hardware.nixosModules.common-pc-ssd

    ./hardware-configuration.nix
    ../../tmpl/efi-luks-btrfs-impermanence.nix

    ../_common/global
    ../_common/users/rajx88

    ../_common/optional/zsa.nix
    ../_common/optional/systemd-boot.nix
    ../_common/optional/ly.nix
    ../_common/optional/mango.nix

    ../_common/optional/pipewire.nix
    ../_common/optional/scarlett-gen4.nix
    ../_common/optional/laptop.nix
    ../_common/optional/openvpn.nix
    ../_common/optional/net-debug.nix
    ../_common/optional/wireguard.nix
    ../_common/optional/netbird.nix
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
    kernelModules = [
      "nvidia"
      "nvidia_modeset"
      "nvidia_drm"
      "nvidia_uvm"
    ];
    kernelParams = [ "nvidia.NVreg_PreserveVideoMemoryAllocations=1" ];
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
  };

  services.hardware.openrgb.enable = true;
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;

  # One-off full charge: `sudo systemctl start battery-full`. Runs until the
  # battery reads 100% or the adapter is unplugged, then restores the Custom
  # limit. The limit itself lives in the Dell firmware, see
  # docs/battery-charge-limit.md.
  systemd.services.battery-full = {
    description = "Charge the battery to 100% once, then restore the limit";
    serviceConfig.RuntimeMaxSec = "12h";
    script = ''
      bat=/sys/class/power_supply/BAT0
      ac=/sys/class/power_supply/AC
      echo Standard > $bat/charge_types
      while [ "$(cat $ac/online)" = 1 ] && [ "$(cat $bat/capacity)" -lt 100 ]; do
        sleep 10
      done
    '';
    postStop = "echo Custom > /sys/class/power_supply/BAT0/charge_types";
  };

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };

    nvidia = {
      prime.offload.enable = false; # no PRIME offload — Intel drives all displays
      modesetting.enable = true;
      powerManagement.enable = false;
      powerManagement.finegrained = false;
      open = true; # required for Blackwell (GB207 / sm_120)
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.latest;
    };

    nvidia-container-toolkit.enable = true;
  };

  # DO NOT TOUCH BEFORE GOOGLING IT.
  system.stateVersion = "23.11"; # Did you read the comment?
}
