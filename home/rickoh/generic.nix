{lib, ...}: {
  imports = [
    ../rajkoh/generic.nix
  ];

  home.username = lib.mkForce "rickoh";
  programs.ssh.enable = lib.mkForce false;
}
