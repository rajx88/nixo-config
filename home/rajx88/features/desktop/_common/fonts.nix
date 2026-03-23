{pkgs, ...}: {
  home.packages = with pkgs; [
    noto-fonts-color-emoji
    twemoji-color-font
    # openmoji-color
    # openmoji-black
    symbola
    # proggyfonts
    # tamsyn
    nerd-fonts.go-mono
    nerd-fonts.jetbrains-mono
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
    # monospace = {
    #   name = "Tamsyn";
    #   size = 12;
    #   package = pkgs.tamsyn;
    # };
    monospace = {
      name = "GoMono Nerd Font Mono";
      size = 12;
      package = pkgs.nerd-fonts.go-mono;
    };
    regular = {
      name = "GoMono Nerd Font";
      size = 12;
      package = pkgs.nerd-fonts.go-mono;
    };
  };
}
