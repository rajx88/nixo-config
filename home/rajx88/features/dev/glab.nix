{pkgs, ...}: {
  home.packages = with pkgs; [
    glab
  ];

  home.persistence."/persist".directories = [
    ".config/glab"
    ".config/glab-cli"
  ];
}
