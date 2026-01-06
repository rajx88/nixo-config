{
  config,
  pkgs,
  ...
}: {
  programs.foot = {
    enable = true;
    # server = {
    #   enable = true;
    # };

    settings = {
      main = {
        include = "${pkgs.foot.themes}/share/foot/themes/tokyonight-night";
        term = "xterm-256color";
        font = "${config.fontProfiles.monospace.name}:size=${toString config.fontProfiles.monospace.size}";
      };

      colors = {
        alpha = "0.85";
      };
      mouse = {
        hide-when-typing = "yes";
      };
    };
  };
}
