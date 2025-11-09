{
  pkgs,
  config,
  ...
}: {
  home.persistence = {
    "/persist/home/rajkoh".directories = [
      # ".config/VSCodium"
      # ".vscode-oss/extensions"
      ".vscode"
      ".config/Code"
    ];
  };
  programs.vscode = {
    enable = true;
    # package = pkgs.vscodium;
    profiles.default = {
      userSettings = {
        # needed for hyprland will crash imeediately without it
        "window.titleBarStyle" = "custom";
        "workbench.colorTheme" = "Rosé Pine Moon";
        "editor.fontFamily" = "${config.fontProfiles.monospace.name}, Consolas, 'Courier New', monospace";
        "editor.fontSize" = 14;
      };

      # Can search for a package:
      # https://search.nixos.org/packages?channel=23.11&from=0&size=50&sort=relevance&type=packages&query=vscode-extensions
      extensions = with pkgs.vscode-extensions;
        [
          github.copilot
          github.copilot-chat
          kamadorueda.alejandra
          jnoortheen.nix-ide
          mkhl.direnv
          ms-vscode.makefile-tools
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
  };
}
