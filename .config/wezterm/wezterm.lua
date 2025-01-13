local wezterm = require("wezterm")
local config = {}

config.font = wezterm.font("IosevkaTerm Nerd Font")
config.font_size = 19
config.line_height = 1.06
config.harfbuzz_features = { "calt=0" }
config.send_composed_key_when_left_alt_is_pressed = true

config.window_decorations = "RESIZE"
config.adjust_window_size_when_changing_font_size = false
config.hide_tab_bar_if_only_one_tab = true
config.scrollback_lines = 5000
config.show_new_tab_button_in_tab_bar = false

config.keys = {
    {
        key = "LeftArrow",
        mods = "OPT",
        action = wezterm.action({ SendString = "\x1bb" }),
    },
    {
        key = "RightArrow",
        mods = "OPT",
        action = wezterm.action({ SendString = "\x1bf" }),
    },
    {
        mods = "CMD",
        key = "d",
        action = wezterm.action.SplitPane({
            direction = "Right",
            size = { Percent = 35 },
        }),
    },
    {
        mods = "CMD",
        key = "w",
        action = wezterm.action.CloseCurrentPane({ confirm = true }),
    },
    {
        mods = "CMD",
        key = "LeftArrow",
        action = wezterm.action.ActivateTabRelative(-1),
    },
    {
        mods = "CMD",
        key = "RightArrow",
        action = wezterm.action.ActivateTabRelative(1),
    },
}

require("theme")(config)

return config
