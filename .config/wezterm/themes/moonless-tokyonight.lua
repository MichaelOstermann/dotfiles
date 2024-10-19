return function(config)
    config.window_frame = {
        active_titlebar_bg = "#1F2029",
        inactive_titlebar_bg = "#1F2029",
    }

    config.colors = {
        foreground = "#6974a6",
        background = "#1F2029",
        cursor_bg = "#6974a6",
        cursor_border = "#6974a6",
        cursor_fg = "#1F2029",
        selection_bg = "#2f3346",
        selection_fg = "none",
        split = "#181921",
        tab_bar = {
            inactive_tab_edge = "none",
            active_tab = {
                bg_color = "#1F2029",
                fg_color = "#6789d0",
            },
            inactive_tab = {
                bg_color = "#1F2029",
                fg_color = "#636d9c",
            },
            inactive_tab_hover = {
                bg_color = "#282a3a",
                fg_color = "#7481B9",
            },
        },
        ansi = {
            "#454c6b",
            "#b05669",
            "#69884b",
            "#907149",
            "#6789d0",
            "#866fb1",
            "#51909f",
            "#555e86",
        },
        brights = {
            "#454c6b",
            "#b05669",
            "#69884b",
            "#907149",
            "#6789d0",
            "{terminal.magenta}",
            "#51909f",
            "#555e86",
        },
    }
end
