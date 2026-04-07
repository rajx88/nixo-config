{pkgs, ...}: {
  home.packages = with pkgs; [
    bruno
    bruno-cli
  ];

  home.persistence."/persist".directories = [".config/bruno"];
}
