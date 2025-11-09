{lib, ...}: {
  imports = [
    ../rajx88/generic.nix
    ../rajx88/features/dev/mise.nix
  ];

  programs.ssh.enable = lib.mkForce false;

  home = {
    username = lib.mkForce "appeltaartu";
    sessionVariables = {
      TERM = lib.mkForce "alacritty";
    };
  };
}
