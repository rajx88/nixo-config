{inputs, ...}: {
  imports = [
    inputs.mango.nixosModules.mango
    ./xwayland.nix
  ];
  programs.mango.enable = true;
  services.greetd.sessionCommand = "mango";
}
