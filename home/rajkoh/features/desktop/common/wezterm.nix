{ config, pkgs, ... }:
{
  programs.wezterm = {
    enable = true;
    extraConfig = /* lua */ ''
      return {
        font = wezterm.font("${config.fontProfiles.monospace.family}"),
        font_size = 12.0,
        hide_tab_bar_if_only_one_tab = true,
        window_close_confirmation = "NeverPrompt",
        set_environment_variables = {
          TERM = 'wezterm',
        },
      }
    '';
  };
}
