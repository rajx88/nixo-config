{pkgs, ...}: {
  home.packages = with pkgs; [
    opencommit
  ];

  home.persistence."/persist".files = [
    ".opencommit"
    ".opencommitignore"
  ];
}
