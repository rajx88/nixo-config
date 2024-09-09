{lib, ...}: {
  imports = [
    ../rajkoh/generic.nix

    ../rajkoh/features/dev/asdf.nix
    ../rajkoh/features/dev/commitizen.nix
  ];

  home.username = lib.mkForce "rickoh";
  programs.ssh.enable = lib.mkForce false;
}
