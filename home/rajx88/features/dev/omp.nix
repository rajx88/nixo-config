{pkgs, ...}: {
  home.packages = [pkgs.omp];

  home.persistence."/persist".directories = [
    ".omp"
  ];
}
