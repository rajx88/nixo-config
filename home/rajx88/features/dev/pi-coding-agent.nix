{pkgs, ...}: {
  home.packages = [pkgs.pi-coding-agent];

  home.persistence."/persist".directories = [
    ".pi"
  ];
}
