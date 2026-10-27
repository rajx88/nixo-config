{ pkgs, inputs, ... }: {
  home.packages = [
    pkgs.bruno
    # nixpkgs' bruno-cli inherits version/src/npmDepsHash from `bruno`, which our
    # overlay shadows with the AppImage package. Take it from nixpkgs directly.
    inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system}.bruno-cli
  ];

  home.persistence."/persist".directories = [ ".config/bruno" ];
}
