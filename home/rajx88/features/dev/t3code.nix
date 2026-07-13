{pkgs, ...}: {
  programs.t3code = {
    enable = true;
    package = pkgs.t3code.override {
      enableCodex = false;
      enableClaude = false;
      enableCursor = false;
      enableOpencode = true;
      enableGitLab = true;
    };
  };

  home.persistence."/persist".directories = [
    ".t3"
  ];
}
