{
  inputs,
  lib,
  pkgs,
  config,
  outputs,
  ...
}: {
  imports =
    [
      inputs.impermanence.nixosModules.home-manager.impermanence
      ../features/cli
    ]
    ++ (builtins.attrValues outputs.homeManagerModules);

  nix = {
    package = lib.mkDefault pkgs.nix;
    settings = {
      experimental-features = ["nix-command" "flakes"];
      warn-dirty = false;
      download-buffer-size = 33554432;
    };
  };

  systemd.user.startServices = "sd-switch";

  programs = {
    home-manager.enable = true;
    git.enable = true;
  };

  xdg = {
    enable = true;
    mimeApps = {
      enable = true;
      defaultApplications = {
        "text/plain" = ["code.desktop"];
        "image/*" = ["brave.desktop"];
        "text/html" = ["brave.desktop"];
        "text/xml" = ["brave.desktop"];
        "x-scheme-handler/http" = ["brave.desktop"];
        "x-scheme-handler/https" = ["brave.desktop"];
      };
    };
    # userDirs = {
    #   enable = true;
    #   createDirectories = true;
    #   extraConfig = {
    #     # XDG_GAMES_DIR = "${config.home.homeDirectory}/games";
    #     XDG_CODE_DIR = "${config.home.homeDirectory}/code";
    #   };
    # };
    # };
  };

  home = {
    username = lib.mkDefault "rajx88";
    homeDirectory = lib.mkDefault "/home/${config.home.username}";
    stateVersion = lib.mkDefault "23.11";
    sessionPath = ["$HOME/.local/bin"];
    sessionVariables = {
      FLAKE = "$HOME/code/nixos-config";
      TERM = "ghostty";
      BROWSER = "brave";
    };

    persistence = {
      "/persist/home/rajx88" = {
        directories = [
          "Documents"
          "Downloads"
          "Pictures"
          "Videos"
          ".local/bin"
          "code"
        ];
        allowOther = true;
      };
    };
  };
}
