{lib, ...}: {
  imports = [
    ../rajkoh/generic.nix

    ../rajkoh/features/dev/asdf.nix
  ];

  home.username = lib.mkForce "rickoh";
  programs.ssh.enable = lib.mkForce false;
}
