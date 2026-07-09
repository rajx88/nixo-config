{pkgs, ...}: {
  home.packages = [pkgs.radar pkgs.radar-desktop];

  home.persistence."/persist".directories = [".radar"];
}
