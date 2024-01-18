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

  nixpkgs = {
    overlays = builtins.attrValues outputs.overlays;
    config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
    };
  };

  nix = {
    package = lib.mkDefault pkgs.nix;
    settings = {
      experimental-features = ["nix-command" "flakes" "repl-flake"];
      warn-dirty = false;
    };
  };

  systemd.user.startServices = "sd-switch";

  programs = {
    home-manager.enable = true;
    git.enable = true;
  };

  # xdg = {
  #   enable = true;
  #   userDirs = {
  #     enable = true;
  #     createDirectories = true;
  #     extraConfig = {
  #       # XDG_GAMES_DIR = "${config.home.homeDirectory}/games";
  #       XDG_CODE_DIR = "${config.home.homeDirectory}/code";
  #     };
  #   };
  # };

  home = {
    username = lib.mkDefault "rajkoh";
    homeDirectory = lib.mkDefault "/home/${config.home.username}";
    stateVersion = lib.mkDefault "23.11";
    sessionPath = ["$HOME/.local/bin"];
    sessionVariables = {
      FLAKE = "$HOME/code/nixos-config";
      TERM = "alacritty";
      # TERM = "wezterm";
      BROWSER = "firefox";
    };

    persistence = {
      "/persist/home/rajkoh" = {
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
