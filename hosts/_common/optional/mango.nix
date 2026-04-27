{inputs, ...}: {
  imports = [
    inputs.mango.nixosModules.mango
  ];
  programs.mango.enable = true;
  programs.xwayland.enable = true;
}
