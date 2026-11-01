{ pkgs, ... }: {
  home.packages = [ pkgs.pokebonk ];

  # Electron userData for the client: display settings, the login cookies, and
  # the game's saves in the profile's localStorage for the pokebonk.com origin.
  #
  # ASCII path on purpose: upstream's productName is "PokéBonk", and impermanence
  # names bind-mount units after the path, but systemd only loads escaped unit
  # filenames — a raw "PokéBonk" unit is silently ignored, leaving the data on
  # the ephemeral root. The wrapper passes --user-data-dir to this path instead.
  home.persistence."/persist".directories = [ ".config/pokebonk" ];
}
