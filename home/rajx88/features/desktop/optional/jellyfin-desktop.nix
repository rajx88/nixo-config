{pkgs, ...}: {
  home.packages = with pkgs; [
    jellyfin-media-player
  ];

  home.persistence."/persist".directories = [
    ".config/jellyfin-desktop"
  ];
}
