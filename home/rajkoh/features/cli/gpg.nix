{pkgs, ...}: {
  home.packages = with pkgs; [
    pinentry
  ];
  programs.gpg = {
    enable = true;
  };
}
