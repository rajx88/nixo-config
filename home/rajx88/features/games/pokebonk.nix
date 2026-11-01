{ pkgs, ... }: {
  home.packages = [ pkgs.pokebonk ];

  # Electron userData for the client: display settings, and the game's saves in
  # the profile's localStorage for the pokebonk.com origin.
  home.persistence."/persist".directories = [ ".config/PokéBonk" ];
}
