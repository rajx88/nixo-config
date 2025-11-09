{
  pkgs,
  lib,
  ...
}: {
  home.packages = with pkgs; [
    (lutris.override {
      extraLibraries = pkgs: [
        # List library dependencies here
      ];
      extraPkgs = pkgs: [
        # List package dependencies here
        pkgs.wineWowPackages.staging
      ];
    })
  ];

  home.persistence = {
    "/persist/home/rajx88" = {
      allowOther = true;
      directories = [
        ".config/lutris"
        ".local/share/lutris"
      ];
    };
  };
}
