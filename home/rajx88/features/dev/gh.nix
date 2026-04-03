{pkgs, ...}: {
  home.packages = with pkgs; [
    gh
  ];

  home.persistence."/persist".directories = [".config/gh"];
}
