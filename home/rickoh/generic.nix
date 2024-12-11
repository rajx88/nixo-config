{lib, ...}: {
  imports = [
    ../rajkoh/generic.nix

    # ../rajkoh/features/dev/asdf.nix
    ../rajkoh/features/dev/mise.nix
  ];

  home.username = lib.mkForce "rickoh";
  programs.ssh.enable = lib.mkForce false;
}
