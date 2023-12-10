return {
    --Pull in the wezterm API
    local wezterm = require "wezterm"
    local mux = wezterm.mux

    wezterm.on("gui-startup", function(cmd)
      local tab, pane, window = mux.spawn_window(cmd or {})
      window:gui_window():maximize()
    end)

    -- see https://wezfurlong.org/wezterm/config/lua/wezterm/target_triple.html for values
    local is_linux = wezterm.target_triple == "x86_64-unknown-linux-gnu"
    local is_windows = wezterm.target_triple == "x86_64-pc-windows-msvc"

    -- This table will hold the configuration.
    local config = {}

    -- In newer versions of wezterm, use the config_builder which will
    -- help provide clearer error messages
    if wezterm.config_builder then
      config = wezterm.config_builder()
    end

    -- This is where you actually apply your config choices
    -- For example, changing the color scheme:
    -- config.color_scheme = "AdventureTime"

    config.colors = require('rose-pine').colors()

    -- Setting text color
    --config.colors = {
    --  foreground = "#FFFFFF"
    --}
    -- set background opacity
    config.window_background_opacity = 0.8
    config.font = wezterm.font_with_fallback {
      "CaskaydiaCove Nerd Font",
      "JetBrains Mono",
      "Hack Nerd Font",
      "Hack",
      "DejaVu Sans Mono",
      "Noto Sans Mono",
      "monospace",
    }
    config.window_close_confirmation = "NeverPrompt"
    -- hide tab bar if only one tab is open
    config.hide_tab_bar_if_only_one_tab = true 
    -- set arch as wsl distro and load it by default
    config.default_domain = is_windows and "WSL:Arch" or nil
    
    config.enable_wayland = false

    -- and finally, return the configuration to wezterm
    return config