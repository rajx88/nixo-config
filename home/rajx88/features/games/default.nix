{ pkgs, ... }: {
  imports = [
    ./lutris.nix
    ./pokebonk.nix
    ./steam.nix
  ];

  home = {
    persistence."/persist".directories = [
      "games"
    ];
  };
}
