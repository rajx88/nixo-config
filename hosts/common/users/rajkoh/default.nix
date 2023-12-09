{ pkgs, config, ... }:
let ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in
{
  users.mutableUsers = true;
  users.users.rajkoh= {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [
      "wheel"
      "video"
      "audio"
    ] ++ ifTheyExist [
      "network"
      "wireshark"
      "i2c"
      "docker"
      "podman"
      "git"
      "libvirtd"
    ];

    packages = [ pkgs.home-manager ];
  };

  home-manager.users.rajkoh = import ../../../../home/rajkoh/${config.networking.hostName}.nix;

  security.pam.services = { swaylock = { }; };
}
