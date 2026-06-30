{pkgs, ...}: {
  home.packages = [pkgs.cursor];

  home.persistence."/persist".directories = [".config/Cursor"];
}
