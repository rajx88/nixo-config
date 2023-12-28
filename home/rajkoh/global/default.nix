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

  #systemd.user.startServices = "sd-switch";

  programs = {
    home-manager.enable = true;
    git.enable = true;
  };

  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      desktop = lib.mkDefault "${config.home.homeDirectory}/Desktop";
      documents = lib.mkDefault "${config.home.homeDirectory}/Documents";
      download = lib.mkDefault "${config.home.homeDirectory}/Downloads";
      music = lib.mkDefault "${config.home.homeDirectory}/Music";
      pictures = lib.mkDefault "${config.home.homeDirectory}/Pictures";
      videos = lib.mkDefault "${config.home.homeDirectory}/Videos";
      extraConfig = {
        XDG_SCRNSHT_DIR = "${config.xdg.userDirs.pictures}/scrnsht";
        XDG_GAMES_DIR = "${config.home.homeDirectory}/games";
      };
    };
  };

  home = {
    username = lib.mkDefault "rajkoh";
    homeDirectory = lib.mkDefault "/home/${config.home.username}";
    stateVersion = lib.mkDefault "22.05";
    sessionPath = ["$HOME/.local/bin"];
    sessionVariables = {
      FLAKE = "$HOME/nix-config";
      TERM = "alacritty";
      BROWSER = "firefox";
    };
  };
}
