{
  pkgs,
  config,
  ...
}: let
  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in {
  imports = [
    ../../optional/1password.nix
  ];

  users.mutableUsers = false;
  users.users.rajx88 = {
    isNormalUser = true;
    shell = pkgs.zsh;

    hashedPasswordFile = "/persist/passwords/user";

    extraGroups =
      [
        "wheel"
        "video"
        "audio"
      ]
      ++ ifTheyExist [
        "network"
        "networkmanager"
        "docker"
        "podman"
        "git"
        "libvirtd"
      ];

    packages = [pkgs.home-manager];
  };

  # homemanager module
  home-manager.users.rajx88 = import ../../../../home/rajx88/${config.networking.hostName}.nix;

  security.pam.services = {
    swaylock = {
      enableGnomeKeyring = true;
    };
  };
}
