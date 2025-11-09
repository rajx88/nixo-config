local M = {}

local new_tab = {
    fg_color = "#2e7de9",
    bg_color = "#e1e2e7",
}

local new_tab_hover = {
    fg_color = "#2e7de9",
    bg_color = "#e1e2e7",
    intensity = "Bold",
}

local inactive_tab_hover = {
    fg_color = "#2e7de9",
    bg_color = "#c4c8da",
}

local active_tab = {
    fg_color = "#e9e9ec",
    bg_color = "#2e7de9",
}

local inactive_tab = {
    fg_color = "#8990b3",
    bg_color = "#c4c8da",
}

function M.colors()
    return {
        foreground = "#3760bf",
        background = "#e1e2e7",
        cursor_bg = "#3760bf",
        cursor_border = "#3760bf",
        cursor_fg = "#e1e2e7",
        selection_bg = "#b6bfe2",
        selection_fg = "#3760bf",
        split = "#2e7de9",
        compose_cursor = "#b15c00",

        ansi = {
            "#e9e9ed",
             "#f52a65",
              "#587539", 
              "#8c6c3e", 
              "#2e7de9", 
              "#9854f1", 
              "#007197", 
              "#6172b0",
        },

        brights = {
            "#a1a6c5", 
            "#f52a65", 
            "#587539",
             "#8c6c3e", 
             "#2e7de9", 
             "#9854f1", 
             "#007197",
              "#3760bf",
        },

        tab_bar = {
            inactive_tab_edge = "#e9e9ec",
            background = "#e1e2e7",
            active_tab = active_tab,
            inactive_tab = inactive_tab,
            inactive_tab_hover = inactive_tab_hover,
            new_tab = new_tab,
            new_tab_hover = new_tab_hover,
        },
    }
end

return M