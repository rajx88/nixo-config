{pkgs, ...}: {
  home.packages = with pkgs; [
    noto-fonts-color-emoji
    twemoji-color-font
    # openmoji-color
    # openmoji-black
    symbola
    # proggyfonts
    # tamsyn
    nerd-fonts.fira-code
    nerd-fonts.caskaydia-mono
  ];

  fonts.fontconfig = {
    enable = true;
    # defaultFonts = {
    #   monospace = ["Tamsyn"];
    #   emoji = ["NotoColorEmoji"];
    # };
  };

  fontProfiles = {
    enable = true;
    monospace = {
      name = "Tamsyn";
      size = 12;
      package = pkgs.tamsyn;
    };
    regular = {
      name = "FiraCode Nerd Font Ret";
      size = 12;
      package = pkgs.nerd-fonts.fira-code;
    };
  };
}
