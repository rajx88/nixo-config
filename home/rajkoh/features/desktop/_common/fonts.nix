{pkgs, ...}: {
  home.packages = with pkgs; [
    # noto-fonts-color-emoji
    twemoji-color-font
    # openmoji-color
    # openmoji-black
    symbola
    proggyfonts
    nerdfonts
  ];

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      monospace = "proggyfonts";
      emoji = "twemoji-color-font";
    };
  };

  fontProfiles = {
    enable = true;
    monospace = {
      # family = "OpenDyslexicM Nerd Font Mono";
      # family = "SauceCodePro Nerd Font Mono";
      # family = "CaskaydiaMono Nerd Font Mono";
      family = "proggy";
      # package = pkgs.nerdfonts.override {fonts = ["CascadiaCode" "Hack" "DejaVuSansMono"];};
      # package = pkgs.nerdfonts;
      package = pkgs.proggyfonts;
    };
    # regular = {
    #   family = "Fira Sans";
    #   package = pkgs.fira;
    # };
  };
}
