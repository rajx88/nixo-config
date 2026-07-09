{pkgs, lib, ...}: {
  home.packages = [pkgs.omp pkgs.bun];

  programs.fish.interactiveShellInit = ''
    omp completions fish | source
  '';

  home.persistence."/persist".directories = [
    ".omp"
  ];
}
