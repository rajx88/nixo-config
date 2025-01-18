{pkgs, ...}: {
  home.packages = with pkgs; [
    # noto-fonts-color-emoji
    twemoji-color-font
    # openmoji-color
    # openmoji-black
    symbola
    proggyfonts
    # nerd-fonts
  ];

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      monospace = ["proggyfonts"];
      emoji = ["twemoji-color-font"];
    };
  };

  fontProfiles = {
    enable = true;
    monospace = {
      # family = "OpenDyslexicM Nerd Font Mono";
      # family = "SauceCodePro Nerd Font Mono";
      # family = "CaskaydiaMono Nerd Font Mono";
      name = "proggyfonts";
      size = 12;
      # package = pkgs.nerd-fonts.override {fonts = ["CascadiaCode" "Hack" "DejaVuSansMono"];};
      # package = pkgs.nerd-fonts;
      package = pkgs.proggyfonts;
    };
    regular = {
      name = "proggyfonts";
      size = 12;
      package = pkgs.proggyfonts;
    };
  };
}
