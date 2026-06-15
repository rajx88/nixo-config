{
  pkgs,
  lib,
  ...
}: {
  home.packages = with pkgs; [
    protonup-qt
    winetricks
    (lutris.override {
      extraLibraries = pkgs: [
        # List library dependencies here
      ];
      extraPkgs = pkgs: [
        # List package dependencies here
        pkgs.wineWow64Packages.staging
      ];
    })
  ];

  home.persistence."/persist".directories = [
    ".config/lutris"
    ".local/share/lutris"
  ];
}
