{pkgs, ...}: {
  programs = {
    mise = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
    };
    zsh.initExtra = ''
      eval "$(${pkgs.mise}/bin/mise activate zsh --shims)"
    '';
  };
}
