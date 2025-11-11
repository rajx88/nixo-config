{
  pkgs,
  lib,
  ...
}: {
  home.packages = with pkgs; [
    # discord
    # (discord.override {
    #   # has troubles showing bar with close/minimize buttons
    #   # withOpenASAR = true;
    #   # withVencord = true;
    #   # nss = nss_latest;
    # })

    discord
    # discocss
  ];

  home.persistence."/persist".directories = [".config/discord"];
}
