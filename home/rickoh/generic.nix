{lib, ...}: {
  imports = [
    ../rajx88/generic.nix

    # ../rajx88/features/dev/asdf.nix
    ../rajx88/features/dev/mise.nix
  ];

  home.username = lib.mkForce "rickoh";
  programs.ssh.enable = lib.mkForce false;
}
