{ pkgs, ... }:
{
  home.packages = [ pkgs.brave-origin ];

  home.persistence."/persist".directories = [ ".config/BraveSoftware/Brave-Origin" ];
}
