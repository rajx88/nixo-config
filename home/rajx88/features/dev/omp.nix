{pkgs, ...}: {
  home.packages = [pkgs.omp];

  programs.fish.interactiveShellInit = ''
    omp completions fish | source
  '';

  home.persistence."/persist".directories = [
    ".omp"
  ];
}
