{pkgs, ...}: {
  programs.vscode = {
    enable = true;
    userSettings = {
      # needed for hyprland will crash imeediately without it
      "window.titleBarStyle" = "custom";
    };
    # package = pkgs.vscodium;
    # extensions = with pkgs.vscode-extensions; [
    # ];
  };
}
