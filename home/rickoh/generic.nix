{lib, ...}: {
  imports = [
    ../rajkoh/generic.nix

    ../rajkoh/features/cli/asdf.nix
  ];

  home.username = lib.mkForce "rickoh";
  programs.ssh.enable = lib.mkForce false;
}
