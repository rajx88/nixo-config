{pkgs, ...}: {
  home.packages = [pkgs.icm];

  home.persistence."/persist".directories = [
    ".local/share/icm"
  ];
}
