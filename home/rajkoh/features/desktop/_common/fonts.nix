{pkgs, ...}: {
  fontProfiles = {
    enable = true;
    monospace = {
      family = "Hack Nerd Font Mono";
      # family = "CaskaydiaMono Nerd Font Mono";
      # package = pkgs.nerdfonts.override {fonts = ["CascadiaCode" "Hack" "DejaVuSansMono"];};
      package = pkgs.nerdfonts;
    };
    regular = {
      family = "Fira Sans";
      package = pkgs.fira;
    };
  };
}
