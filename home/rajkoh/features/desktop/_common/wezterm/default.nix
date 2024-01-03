{
  config,
  pkgs,
  ...
}: {
  xdg = {
    configFile."wezterm" = {
      source = ./config;
      target = "wezterm/lua";
      recursive = true;
    };
  };

  programs.wezterm = {
    enable = true;
    enableZshIntegration = true;

    extraConfig =
      /*
      lua
      */
      ''
        --Pull in the wezterm API
        local wezterm = require "wezterm"

        -- This table will hold the configuration.
        local config = {}

        -- In newer versions of wezterm, use the config_builder which will
        -- help provide clearer error messages
        if wezterm.config_builder then
            config = wezterm.config_builder()
        end

        config.font = wezterm.font_with_fallback {
            "${config.fontProfiles.monospace.family}",
            "Hack Nerd Font",
            "CaskaydiaCove Nerd Font",
            "JetBrains Mono",
            "DejaVu Sans Mono",
            "Noto Sans Mono",
            "monospace",
        }

        config.colors = require('lua/tokyonight_night').colors()

        config.window_close_confirmation = "NeverPrompt"
        -- hide tab bar if only one tab is open
        config.hide_tab_bar_if_only_one_tab = true

        config.enable_wayland = false

        -- and finally, return the configuration to wezterm
        return config
      '';
  };
}
