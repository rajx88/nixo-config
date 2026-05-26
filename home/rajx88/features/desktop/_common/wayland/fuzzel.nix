{pkgs, ...}: {
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        font = "Atkinson Hyperlegible Mono:size=14";
        terminal = "ghostty -e";
        layer = "overlay";
        width = 45;
        lines = 20;
        horizontal-pad = 50;
        vertical-pad = 12;
      };
      colors = {
        background = "1a1b26ee";
        text = "c0caf5ff";
        prompt = "7aa2f7ff";
        placeholder = "565f89ff";
        input = "c0caf5ff";
        match = "7aa2f7ff";
        selection = "283457ff";
        selection-text = "c0caf5ff";
        selection-match = "2ac3deff";
        counter = "565f89ff";
        border = "7aa2f7ff";
      };
      border = {
        width = 2;
        radius = 8;
      };
    };
  };
}
