{pkgs, ...}: {
  home.packages = with pkgs; [
    # noto-fonts-color-emoji
    twemoji-color-font
    # openmoji-color
    # openmoji-black
    symbola
  ];

  fontProfiles = {
    enable = true;
    monospace = {
      # family = "OpenDyslexicM Nerd Font Mono";
      family = "SauceCodePro Nerd Font Mono";
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
