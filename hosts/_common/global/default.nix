{
  inputs,
  outputs,
  ...
}: {
  imports =
    [
      inputs.home-manager.nixosModules.home-manager
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

  # fix qt6 plugins
  environment.profileRelativeSessionVariables = {
    QT_PLUGIN_PATH = ["/lib/qt-6/plugins"];
  };

  # Enable polkit for system authentication
  security.polkit.enable = true;
  # security.soteria.enable = true;

  services.envfs.enable = true;

  hardware.enableRedistributableFirmware = true;
}
