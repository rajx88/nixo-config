{
  lib,
  outputs,
  ...
}: {
  imports = [
    ./global
  ];

  # Disable impermanence
  home.persistence = lib.mkForce {};

  nixpkgs = {
    overlays = builtins.attrValues outputs.overlays;
    config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
    };
  };
}
