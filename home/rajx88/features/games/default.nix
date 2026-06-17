{pkgs, ...}: {
  imports = [
    ./lutris.nix
    ./steam.nix
  ];

  home = {
    persistence."/persist".directories = [
      "games"
    ];
  };
}
