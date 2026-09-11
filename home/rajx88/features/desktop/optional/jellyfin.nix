{pkgs, ...}: {
  home.persistence."/persist".directories = [
    ".local/share/jellyfin-desktop"
  ];

  home.packages = with pkgs; [
    jellyfin-desktop
  ];
}
