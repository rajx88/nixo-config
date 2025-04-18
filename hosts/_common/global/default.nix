{
  inputs,
  outputs,
  ...
}: {
  imports =
    [
      inputs.home-manager.nixosModules.home-manager
      ./auto-upgrade.nix
      ./gamemode.nix
      ./locale.nix
      ./nix.nix
      ./nix-ld.nix
      ./openssh.nix
      ./podman.nix
      ./steam-hardware.nix
      ./systemd-initrd.nix
      ./systemd.nix
      ./zsh.nix
    ]
    ++ (builtins.attrValues outputs.nixosModules);

  home-manager.useGlobalPkgs = true;
  home-manager.extraSpecialArgs = {
    inherit inputs outputs;
  };

  nixpkgs = {
    overlays = builtins.attrValues outputs.overlays;
    config = {
      allowUnfree = true;
    };
  };

  hardware.enableRedistributableFirmware = true;
}
