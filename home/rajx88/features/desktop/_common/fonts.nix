{pkgs, ...}: {
  home.packages = with pkgs; [
    noto-fonts-color-emoji
    twemoji-color-font
    # openmoji-color
    # openmoji-black
    symbola
    # proggyfonts
    # tamsyn
    # nerd-fonts.go-mono
    nerd-fonts.jetbrains-mono
    atkinson-hyperlegible-mono
    comic-mono
  ];

  fonts.fontconfig = {
    enable = true;
  };

  fontProfiles = {
    enable = true;
    monospace = {
      name = "Atkinson Hyperlegible Mono";
      size = 13;
      package = pkgs.atkinson-hyperlegible-mono;
    };
    regular = {
      name = "Atkinson Hyperlegible Mono";
      size = 13;
      package = pkgs.atkinson-hyperlegible-mono;
    };
    # monospace = {
    #   name = "Comic Mono";
    #   size = 13;
    #   package = pkgs.comic-mono;
    # };
    # regular = {
    #   name = "Comic Mono";
    #   size = 13;
    #   package = pkgs.comic-mono;
    # };
  };
}
