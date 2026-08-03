{pkgs, ...}: {
  home.packages = [pkgs.ladybird];

  home.persistence."/persist".directories = [".config/Ladybird"];
}
