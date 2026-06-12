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
        "image/*" = ["brave-origin.desktop"];
        "text/html" = ["brave-origin.desktop"];
        "text/xml" = ["brave-origin.desktop"];
        "x-scheme-handler/http" = ["brave-origin.desktop"];
        "x-scheme-handler/https" = ["brave-origin.desktop"];
      };
    };
    userDirs = {
      enable = true;
      createDirectories = true;
      extraConfig = {
        GAMES = "${config.home.homeDirectory}/games";
        CODE = "${config.home.homeDirectory}/code";
        SCRNSHTS = "${config.home.homeDirectory}/Pictures/scrnshts";
      };
    };
  };

  dconf = {
    enable = true;
    settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        gtk-enable-primary-paste = true;
      };
    };
  };

  home = {
    username = lib.mkDefault "rajx88";
    homeDirectory = lib.mkDefault "/home/${config.home.username}";
    stateVersion = lib.mkDefault "26.05";
    sessionPath = ["$HOME/.local/bin"];
    sessionVariables = {
      FLAKE = "$HOME/code/nix/nixo-config";
      NH_FLAKE = "$HOME/code/nix/nixo-config";
      TERM = "ghostty";
      BROWSER = "brave-origin";
      VAULT_PATH = "${config.home.homeDirectory}/code/notes";
    };

    persistence."/persist".directories = [
      "Documents"
      "Downloads"
      "Pictures"
      "Videos"
      ".local/bin"
      "code"
      ".docker"
    ];
  };
}
