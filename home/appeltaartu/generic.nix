{lib, ...}: {
  imports = [
    ../rajkoh/generic.nix
    ../rajkoh/features/dev/mise.nix
  ];

  programs.ssh.enable = lib.mkForce false;

  home = {
    username = lib.mkForce "appeltaartu";
    sessionVariables = {
      TERM = lib.mkForce "alacritty";
    };
  };
}
