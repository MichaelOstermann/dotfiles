-- Load the theme
require("theme")

-- Watch the theme for changes and reload
local handle = vim.uv.new_fs_event()
vim.uv.fs_event_start(
    handle,
    vim.env.HOME .. "/.config/nvim/lua/theme.lua",
    {},
    vim.schedule_wrap(function(err)
        if not err then
            package.loaded["theme"] = nil
            require("theme")
        end
    end)
)
