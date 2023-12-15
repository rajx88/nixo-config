{ pkgs, ... }:

{
  # check with later releases if they have bumped the electron version
  nixpkgs.config.permittedInsecurePackages = [
    "electron-25.9.0"
  ];

  home.packages = with pkgs; [
    obsidian
  ];

}
