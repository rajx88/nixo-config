{
  pkgs,
  ...
}: let
  steam-with-pkgs = pkgs.steam.override {
    extraPkgs = pkgs:
      with pkgs; [
        libxcursor
        libxi
        libxinerama
        libxscrnsaver
        libpng
        libpulseaudio
        libvorbis
        stdenv.cc.cc.lib
        libkrb5
        keyutils
        mangohud
      ];
  };
in {
  home.packages = with pkgs; [
    steam-with-pkgs
    mangohud
    protontricks
  ];

  home.persistence."/persist".directories = [
    ".local/share/Steam"
  ];
}
