{lib, ...}: {
  imports = [
    ../rajkoh/generic.nix

    ../rajkoh/features/dev/asdf.nix
  ];

  home.username = lib.mkForce "appeltaartu";
  programs.ssh.enable = lib.mkForce false;
}
