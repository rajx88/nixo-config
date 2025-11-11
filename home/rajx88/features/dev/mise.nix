{pkgs, ...}: {
  home.persistence."/persist".directories = [".local/share/mise"];
  programs = {
    mise = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    };
    zsh.initContent = ''
    eval "$(${pkgs.mise}/bin/mise activate zsh --shims)"
    '';
  };
}
