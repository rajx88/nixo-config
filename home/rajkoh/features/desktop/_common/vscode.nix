{pkgs, ...}: {
  programs.vscode = {
    enable = true;
    userSettings = {
      # needed for hyprland will crash imeediately without it
      "window.titleBarStyle" = "custom";
      "workbench.colorTheme" = "Rosé Pine Moon";
    };
    # package = pkgs.vscodium;
    extensions = with pkgs.vscode-extensions;
      [
        github.copilot
        github.copilot-chat
        kamadorueda.alejandra
        jnoortheen.nix-ide
        mkhl.direnv
      ]
      ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace
      [
        {
          name = "rose-pine";
          publisher = "mvllow";
          version = "2.9.0";
          sha256 = "ibx19iDUXumpc1vTIUubceFyWyD7nUEBlunFDMcdW6E=";
        }
      ];
  };
}
