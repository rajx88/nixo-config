{ pkgs, lib, ... }:

{

  home.packages = with pkgs; [ 
    # discord
    (discord.override {
      withOpenASAR = true;
      withVencord = true; 
    })
  ];
}
