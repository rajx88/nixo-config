{pkgs, ...}: {
  home.packages = [pkgs.engram];

  home.persistence."/persist".directories = [
    ".engram"
  ];
}
