{pkgs, ...}: {
  programs.vscode = {
    enable = true;
    userSettings = {
      # needed for hyprland will crash imeediately without it
      "window.titleBarStyle" = "custom";
    };
    # package = pkgs.vscodium;
    extensions = with pkgs.vscode-extensions; [
      github.copilot
      github.copilot-chat
      kamadorueda.alejandra
      jnoortheen.nix-ide
      mkhl.direnv
    ];
    # ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace
    # [
    #   {
    #     name = "tokyo-night";
    #     publisher = "Avetis";
    #     version = "1.0.1";
    #     sha256 = "1hp6gjh4xp2m1xlm1jsdzxw9d8frkiidhph6nvl24d0h8z34w49g";
    #   }
    # ];
  };
}
