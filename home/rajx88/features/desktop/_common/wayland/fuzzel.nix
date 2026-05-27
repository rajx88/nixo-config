{
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        font = "Atkinson Hyperlegible Mono:size=12";
        terminal = "ghostty -e";
        layer = "overlay";
        width = 45;
        lines = 20;
        horizontal-pad = 50;
        vertical-pad = 12;
      };
      colors = {
        background = "15141bee";
        text = "edeceeff";
        prompt = "a277ffff";
        placeholder = "6d6d6dff";
        input = "edeceeff";
        match = "61ffcaff";
        selection = "3d375eff";
        selection-text = "edeceeff";
        selection-match = "61ffcaff";
        counter = "6d6d6dff";
        border = "a277ffff";
      };
      border = {
        width = 2;
        radius = 8;
      };
    };
  };
}
