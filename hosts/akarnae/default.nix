# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ pkgs, inputs, ... }: {
  imports = [ 
    inputs.hardware.nixosModules.common-cpu-intel
    inputs.hardware.nixosModules.common-gpu-nvidia
    inputs.hardware.nixosModules.common-pc-ssd
   
    ./hardware-configuration.nix
    ./disko-config.nix

    ../common/global
    ../common/users/rajkoh

    ../common/optional/systemd-boot.nix
    ../common/optional/gnome.nix
    ../common/optional/pipewire.nix

   ];

   networking = {
     hostName = "akarnae";
     useDHCP = true;
   };

   boot = {
     kernelPackages = pkgs.linuxKernel.packages.linux_zen;
   };

   # DO NOT TOUCH BEFORE GOOGLING IT.
   system.stateVersion = "23.11"; # Did you read the comment?
}

