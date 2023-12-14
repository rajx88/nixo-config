{ pkgs, lib, ... }:

{

  home = {
    packages = with pkgs; [ 
      # discord
      (discord.override {
        # has troubles showing bar with close/minimize buttons
        # withOpenASAR = true;
        withVencord = true; 
      })
    ];

    sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };
  };
}
