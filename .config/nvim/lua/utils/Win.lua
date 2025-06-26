local Buf = require("utils.Buf")
local au = require("utils.autocommand")

local M = {}
M.__index = M

function M.of(id)
    return setmetatable({
        id = id,
    }, M)
end

function M.create(buf, enter, options)
    return M.of(vim.api.nvim_open_win(buf, enter, options))
end

function M.current()
    return M.of(vim.api.nvim_get_current_win())
end

function M:buf()
    return Buf.of(vim.api.nvim_win_get_buf(self.id))
end

function M:set_buf(buf)
    vim.api.nvim_win_set_buf(self.id, buf)
    return self
end

function M:focus()
    vim.api.nvim_set_current_win(self.id)
    return self
end

function M:set_cursor(row, col)
    vim.api.nvim_win_set_cursor(self.id, { row, col })
    return self
end

function M:get_cursor()
    return vim.api.nvim_win_get_cursor(self.id)
end

function M:get_row()
    return self:get_cursor()[1]
end

function M:get_col()
    return self:get_cursor()[2]
end

function M:go_to_top()
    return self:set_cursor(1, 0)
end

function M:go_to_bottom()
    return self:set_cursor(self:buf():line_count(), 0)
end

function M:go_to_next()
    local max = self:buf():line_count()
    local row = self:get_row()
    if row == max then
        self:set_cursor(1, 0)
    else
        self:set_cursor(row + 1, 0)
    end
    return self
end

function M:go_to_prev()
    local max = self:buf():line_count()
    local row = self:get_row()
    if row == 1 then
        self:set_cursor(max, 0)
    else
        self:set_cursor(row - 1, 0)
    end
    return self
end

function M:enter(fn)
    return vim.api.nvim_win_call(self.id, fn)
end

function M:get_scrolltop()
    return self:enter(function()
        return vim.fn.line("w0")
    end)
end

function M:on_scroll(fn)
    local win = self
    local prev = win:get_scrolltop()
    -- TODO dispose?
    au("WinScrolled", function()
        local next = win:get_scrolltop()
        if prev ~= next then
            prev = next
            fn(next)
        end
    end)
    return self
end

function M:scroll_to(row)
    local height = vim.api.nvim_win_get_height(self.id)
    self:enter(function()
        local view = vim.fn.winsaveview()
        view.topline = math.max(row - math.floor(height / 2), 1)
        vim.fn.winrestview(view)
    end)
    return self
end

function M:enforce_single_line()
    if self:line_count() > 1 then
        local line = vim.trim(table.concat(self:get_lines(), " "))
        self:set_lines(1, -1, { line })
        self:set_cursor(1, #line + 1)
    end
    return self
end

function M:set_cursorline(enabled)
    vim.api.nvim_set_option_value("cursorline", enabled, { win = self.id })
    return self
end

function M:set_title(title)
    vim.api.nvim_win_set_config(self.id, { title = title })
    return self
end

function M:set_config(options)
    options = vim.tbl_extend("force", vim.api.nvim_win_get_config(self.id), options)
    vim.api.nvim_win_set_config(self.id, options)
    return self
end

function M:set_buftype(...)
    self:buf():set_buftype(...)
    return self
end

function M:set_bufhidden(...)
    self:buf():set_bufhidden(...)
    return self
end

function M:set_buflisted(...)
    self:buf():set_buflisted(...)
    return self
end

function M:set_filetype(...)
    self:buf():set_filetype(...)
    return self
end

function M:set_modifiable(...)
    self:buf():set_modifiable(...)
    return self
end

function M:on_cursor_moved(...)
    self:buf():on_cursor_moved(...)
    return self
end

function M:get_file_path(...)
    return self:buf():get_file_path(...)
end

function M:start_treesitter(...)
    self:buf():start_treesitter(...)
    return self
end

function M:stop_treesitter(...)
    self:buf():stop_treesitter(...)
    return self
end

function M:line_count(...)
    return self:buf():line_count(...)
end

function M:get_lines(...)
    return self:buf():get_lines(...)
end

function M:set_lines(...)
    self:buf():set_lines(...)
    return self
end

function M:clear_lines(...)
    self:buf():clear_lines(...)
    return self
end

function M:highlight_line(...)
    self:buf():highlight_line(...)
    return self
end

function M:highlight_range(...)
    self:buf():highlight_range(...)
    return self
end

function M:clear_highlights(...)
    self:buf():clear_highlights(...)
    return self
end

function M:is_loaded(...)
    return self:buf():is_loaded(...)
end

function M:on_focus(...)
    self:buf():on_focus(...)
    return self
end

function M:on_content_changed(...)
    self:buf():on_content_changed(...)
    return self
end

function M:map(...)
    self:buf():map(...)
    return self
end

return M
