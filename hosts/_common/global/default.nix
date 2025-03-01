# This file (and the global directory) holds config that i use on all hosts
{
  pkgs,
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
      ./openssh.nix
      ./podman.nix
      ./steam-hardware.nix
      ./systemd-initrd.nix
      ./systemd.nix
      ./zsh.nix
    ]
    ++ (builtins.attrValues outputs.nixosModules);

  home-manager.extraSpecialArgs = {inherit inputs outputs;};

  nixpkgs = {
    overlays = builtins.attrValues outputs.overlays;
    config = {
      allowUnfree = true;
    };
  };

  environment.profileRelativeSessionVariables = {
    QT_PLUGIN_PATH = ["/lib/qt-6/plugins"];
  };

  hardware.enableRedistributableFirmware = true;
}
