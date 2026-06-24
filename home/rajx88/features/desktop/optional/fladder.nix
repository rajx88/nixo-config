{pkgs, ...}: {
  home.packages = with pkgs; [
    fladder
  ];

  home.persistence."/persist".directories = [
    ".local/share/nl.jknaapen.fladder"
  ];
}
