local M = {}

local new_tab = {
    fg_color = "#7aa2f7",
    bg_color = "#24283b",
}

local new_tab_hover = {
    fg_color = "#7aa2f7",
    bg_color = "#24283b",
    intensity = "Bold",
}

local inactive_tab_hover = {
    fg_color = "#7aa2f7",
    bg_color = "#292e42",
}

local inactive_tab = {
    fg_color = "#545c7e",
    bg_color = "#292e42",
}

local active_tab = {
    fg_color = "#1f2335",
    bg_color = "#7aa2f7",
}

function M.colors()
    return {
        foreground = "#c0caf5",
        background = "#24283b",
        cursor_bg = "#c0caf5",
        cursor_border = "#c0caf5",
        cursor_fg = "#24283b",
        selection_bg = "#2e3c64",
        selection_fg = "#c0caf5",
        split = "#7aa2f7",
        compose_cursor = "#ff9e64",

        ansi = {
            "#1d202f", "#f7768e", "#9ece6a", "#e0af68", "#7aa2f7", "#bb9af7", "#7dcfff", "#a9b1d6",
        },

        brights = {
            "#414868", "#f7768e", "#9ece6a", "#e0af68", "#7aa2f7", "#bb9af7", "#7dcfff", "#c0caf5",
        },

        tab_bar = {
            inactive_tab_edge = "#1f2335",
            background = "#24283b",
            active_tab = active_tab,
            inactive_tab = inactive_tab,
            inactive_tab_hover = inactive_tab_hover,
            new_tab = new_tab,
            new_tab_hover = new_tab_hover,
        },
    }
end

return M