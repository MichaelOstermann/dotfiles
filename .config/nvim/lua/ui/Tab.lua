local Win = require("utils.Win")
local Path = require("utils.Path")
local signal = require("signals.signal")

local M = {}
M.__index = M

local initial_tab_id = vim.api.nvim_get_current_tabpage()

function M.create(options)
    return setmetatable({
        id = nil,
        did_mount = signal(false),
        callbacks = {
            on_mount = {},
            on_before_open = {},
        },
    }, M)
end

function M:open()
    for _, callback in ipairs(self.callbacks.on_before_open) do
        callback(self)
    end

    if not self.id then
        vim.cmd("tabnew")
        self.id = vim.api.nvim_get_current_tabpage()
    else
        vim.api.nvim_set_current_tabpage(self.id)
    end

    if not self.did_mount:peek() then
        for _, callback in ipairs(self.callbacks.on_mount) do
            callback(self)
        end
        self.did_mount:set(true)
    end
end

function M:close()
    vim.api.nvim_set_current_tabpage(initial_tab_id)
    return self
end

function M:close_and_edit(path, range)
    self:close()
    Path.of(path):edit()

    if range then
        Win.current()
            :scroll_to(range:get_row_start())
            :set_cursor(range:get_row_start(), range:get_col_start())
    end

    return self
end

function M:on_mount(callback)
    table.insert(self.callbacks.on_mount, callback)
    return self
end

function M:on_before_open(callback)
    table.insert(self.callbacks.on_before_open, callback)
    return self
end

return M
