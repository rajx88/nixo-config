local M = {}

local new_tab = {
    fg_color = "#82aaff",
    bg_color = "#222436",
}

local new_tab_hover = {
    fg_color = "#82aaff",
    bg_color = "#222436",
    intensity = "Bold",
}

local inactive_tab_hover = {
    fg_color = "#82aaff",
    bg_color = "#2f334d",
}

local inactive_tab = {
    fg_color = "#545c7e",
    bg_color = "#2f334d",
}

local active_tab = {
    fg_color = "#1e2030",
    bg_color = "#82aaff",
}

function M.colors()
    return {
        foreground = "#c8d3f5",
        background = "#222436",
        cursor_bg = "#c8d3f5",
        cursor_border = "#c8d3f5",
        cursor_fg = "#222436",
        selection_bg = "#2d3f76",
        selection_fg = "#c8d3f5",
        split = "#82aaff",
        compose_cursor = "#ff966c",

        ansi = {
            "#1b1d2b", "#ff757f", "#c3e88d", "#ffc777", "#82aaff", "#c099ff", "#86e1fc", "#828bb8"
        },

        brights = {
            "#444a73", "#ff757f", "#c3e88d", "#ffc777", "#82aaff", "#c099ff", "#86e1fc", "#c8d3f5"
        },

        tab_bar = {
            inactive_tab_edge = "#1e2030",
            background = "#222436",
            active_tab = active_tab,
            inactive_tab = inactive_tab,
            inactive_tab_hover = inactive_tab_hover,
            new_tab = new_tab,
            new_tab_hover = new_tab_hover,
        },
    }
end

return M