{config, lib, ...}: let
  scale = (builtins.head (lib.filter (m: m.primary) config.monitors)).scale;
in {
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        font = "${config.fontProfiles.monospace.name}:size=${toString (builtins.floor (config.fontProfiles.monospace.size * scale))}";
        terminal = "ghostty -e";
        layer = "overlay";
        width = builtins.floor (45 * scale);
        lines = 20;
        horizontal-pad = builtins.floor (50 * scale);
        vertical-pad = builtins.floor (12 * scale);
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
        width = builtins.floor (2 * scale);
        radius = builtins.floor (8 * scale);
      };
    };
  };
}
