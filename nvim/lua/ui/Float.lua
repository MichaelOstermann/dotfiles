local Win = require("utils.Win")
local Buf = require("utils.Buf")
local au = require("utils.autocommand")
local signal = require("signals.signal")
local effect = require("signals.effect")
local batch = require("signals.batch")
local computed = require("signals.computed")

local M = {}
M.__index = M
setmetatable(M, { __index = Win })

local msgarea_height = 1
local statusline_height = 1

M.max_width = signal(vim.o.columns)
M.max_height = signal(vim.o.lines - msgarea_height - statusline_height)
au("VimResized", function()
    M.max_width:set(vim.o.columns)
    M.max_height:set(vim.o.lines - msgarea_height - statusline_height)
end)

local function get_value(x, fallback)
    if type(x) == "nil" then
        return fallback
    elseif type(x) == "number" then
        return x
    elseif type(x) == "function" then
        return x() or fallback
    else
        return x:get() or fallback
    end
end

function M.create(options)
    local float = setmetatable({
        row = signal(0),
        col = signal(0),
        did_mount = signal(false),
        callbacks = {
            on_mount = {},
        },
    }, M)

    local border_width = options.border and 2 or 0

    float.top = computed(function()
        return get_value(options.top, 0)
    end)

    float.left = computed(function()
        return get_value(options.left, 0) + (options.margin_left or 0)
    end)

    float.height = computed(function()
        local max = M.max_height:get() - float.top:get() - border_width
        local height = get_value(options.height, max)
        return math.min(height, max)
    end)

    float.width = computed(function()
        local max = M.max_width:get() - float.left:get() - border_width
        local width = get_value(options.width, max) - (options.margin_left or 0)
        return math.min(width, max)
    end)

    float.right = computed(function()
        return float.left:get() + float.width:get() + border_width
    end)

    float.bottom = computed(function()
        return float.top:get() + float.height:get() + border_width
    end)

    float:on_mount(function()
        local buf = Buf.create(false, true)

        float.id = vim.api.nvim_open_win(buf.id, options.focus == true, {
            title = options.title,
            relative = "editor",
            row = float.top:get(),
            col = float.left:get(),
            width = float.width:get(),
            height = float.height:get(),
            style = "minimal",
            border = options.border,
        })

        float:set_filetype("Custom")

        float:on_cursor_moved(function()
            float.row:set(float:get_row())
            float.col:set(float:get_col())
        end)

        effect(function()
            float:set_config({
                row = float.top:get(),
                col = float.left:get(),
                width = float.width:get(),
                height = float.height:get(),
            })
        end)
    end)

    return float
end

function M:on_mount(callback)
    table.insert(self.callbacks.on_mount, callback)
    return self
end

function M:open()
    if self.did_mount:peek() then
        return
    end
    for _, callback in ipairs(self.callbacks.on_mount) do
        callback(self)
    end
    self.did_mount:set(true)
    self.callbacks.on_mount = {}
    return self
end

function M:set_cursor(row, col)
    Win.set_cursor(self, row, col)
    self.row:set(row)
    self.col:set(col)
    return self
end

return M
