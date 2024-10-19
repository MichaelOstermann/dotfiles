return function(config)
    config.window_frame = {
        active_titlebar_bg = "{{editor.background}}",
        inactive_titlebar_bg = "{{editor.background}}",
    }

    config.colors = {
        foreground = "{{sidebar.foreground}}",
        background = "{{editor.background}}",
        cursor_bg = "{{sidebar.foreground}}",
        cursor_border = "{{sidebar.foreground}}",
        cursor_fg = "{{editor.background}}",
        selection_bg = "{{editor.selection}}",
        selection_fg = "none",
        split = "{{border}}",
        tab_bar = {
            inactive_tab_edge = "none",
            active_tab = {
                bg_color = "{{editor.background}}",
                fg_color = "{{accent}}",
            },
            inactive_tab = {
                bg_color = "{{editor.background}}",
                fg_color = "{{statusline.foreground}}",
            },
            inactive_tab_hover = {
                bg_color = "{{editor.highlight}}",
                fg_color = "{{editor.foreground}}",
            },
        },
        ansi = {
            "{{terminal.black}}",
            "{{terminal.red}}",
            "{{terminal.green}}",
            "{{terminal.yellow}}",
            "{{terminal.blue}}",
            "{{terminal.magenta}}",
            "{{terminal.cyan}}",
            "{{terminal.white}}",
        },
        brights = {
            "{{terminal.black}}",
            "{{terminal.red}}",
            "{{terminal.green}}",
            "{{terminal.yellow}}",
            "{{terminal.blue}}",
            "{terminal.magenta}",
            "{{terminal.cyan}}",
            "{{terminal.white}}",
        },
    }
end
