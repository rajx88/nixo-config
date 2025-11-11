{pkgs, ...}: {
  home.packages = with pkgs; [
    ferdium
  ];

  home.persistence."/persist".directories = [
    ".config/Ferdium"
  ];
}
