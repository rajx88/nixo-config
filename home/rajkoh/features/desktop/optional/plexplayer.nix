{pkgs, ...}: {
  home.packages = with pkgs; [
    plex-media-player
  ];
}
