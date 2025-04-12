{lib, ...}: {
  imports = [
    ../rajkoh/generic.nix
  ];

  home.username = lib.mkForce "appeltaartu";
  programs.ssh.enable = lib.mkForce false;
}
