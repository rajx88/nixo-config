{ pkgs, ... }: {
  home.packages = [ pkgs.spotifast ];

  # Settings live in ~/.config/spotifast and session/history/logs in
  # ~/.local/state/spotifast; the ~/.cache/spotifast audio/artwork/lyrics caches
  # are disposable and intentionally left off the ephemeral root.
  home.persistence."/persist".directories = [
    ".config/spotifast"
    ".local/state/spotifast"
  ];
}
