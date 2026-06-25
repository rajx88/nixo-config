{pkgs, ...}: {
  home.packages = with pkgs; [
    cider-2
  ];

  home.persistence."/persist".directories = [
    ".config/Cider"
  ];
}
