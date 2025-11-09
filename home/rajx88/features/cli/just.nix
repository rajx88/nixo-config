{pkgs, ...}: {
  home.packages = with pkgs; [
    just
  ];

  programs.zsh = {
    shellAliases = {
      j = "just";
    };
  };
}
