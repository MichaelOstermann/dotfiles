local Float = require("ui.Float")
local Buf = require("utils.Buf")
local Path = require("utils.Path")
local signal = require("signals.signal")

local M = {}
M.__index = M
setmetatable(M, { __index = Float })

function M.create(options)
    local float = Float.create(options)
    setmetatable(float, M)

    -- Currently displayed file.
    float.current = Path.of()

    -- Currently loading file.
    float.queued = nil

    float:on_mount(function()
        float:set_modifiable(false)
    end)

    return float
end

function M:show_file(path, range)
    local next_path = Path.of(path)

    local function highlight(range)
        self:clear_highlights()
        if range then
            self:highlight_range("IncSearch", range)
            self:scroll_to(range:get_row_start())
            self:set_cursor(range:get_row_start(), range:get_col_start())
        else
            self:scroll_to(1)
            self:set_cursor(1, 0)
        end
    end

    if self.queued then
        self.queued = { path = next_path, range = range }
        return
    end

    if self.current:eq(next_path) then
        highlight(range)
        return
    end

    self.queued = { path = next_path, range = range }

    next_path:read_lines(function(lines)
        local queued = self.queued
        self.queued = nil

        -- Queued up another file while loading this one.
        if not queued.path:eq(next_path) then
            self:show_file(queued.path.path, queued.range)
        elseif #lines == 0 then
            local buf = Buf.create(false, true)
            self:set_buf(buf.id)
            self:set_modifiable(false)
            self.current = next_path
            highlight(range)
        else
            self:stop_treesitter()

            self:set_modifiable(true)
            self:set_lines(1, -1, lines)
            self:set_modifiable(false)
            self.current = next_path
            highlight(range)

            if vim.fn.getfsize(path) <= 1024 * 10 then
                self:start_treesitter(path)
            end
        end
    end)
end

return M
