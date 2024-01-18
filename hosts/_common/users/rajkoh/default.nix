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

  users.mutableUsers = true;
  users.users.rajkoh = {
    isNormalUser = true;
    shell = pkgs.zsh;

    initialHashedPassword = "";
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
  home-manager.users.rajkoh = import ../../../../home/rajkoh/${config.networking.hostName}.nix;

  security.pam.services = {swaylock = {};};
}
