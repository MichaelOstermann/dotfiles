local Path = require("utils.Path")
local au = require("utils.autocommand")

local M = {}
M.__index = M

local ns = vim.api.nvim_create_namespace("")

function M.of(id)
    return setmetatable({
        id = id,
    }, M)
end

function M.create(listed, scratch)
    return M.of(vim.api.nvim_create_buf(listed, scratch))
end

function M.current()
    return M.of(vim.api.nvim_get_current_buf())
end

function M:line_count()
    return vim.api.nvim_buf_line_count(self.id)
end

function M:set_filetype(filetype)
    vim.api.nvim_set_option_value("filetype", filetype or "", { buf = self.id })
    return self
end

function M:set_modifiable(modifiable)
    vim.api.nvim_set_option_value("modifiable", modifiable, { buf = self.id })
    return self
end

function M:on_cursor_moved(cb)
    au({ "CursorMoved", "CursorMovedI" }, cb, { buffer = self.id })
    return self
end

function M:get_file_path()
    return vim.api.nvim_buf_get_name(self.id)
end

function M:start_treesitter(path)
    path = path or self:get_file_path()
    local filetype = Path.of(path):filetype()
    local lang = vim.treesitter.language.get_lang(filetype)
    pcall(vim.treesitter.start, self.id, lang)
    return self
end

function M:stop_treesitter()
    vim.treesitter.stop(self.id)
    return self
end

function M:get_lines()
    return vim.api.nvim_buf_get_lines(self.id, 0, -1, false)
end

function M:set_lines(row_start, row_end, lines)
    vim.api.nvim_buf_set_lines(self.id, row_start - 1, row_end, false, lines)
    return self
end

function M:clear_lines()
    vim.api.nvim_buf_set_lines(self.id, 0, -1, false, {})
    return self
end

function M:highlight_line(name, line)
    pcall(vim.hl.range, self.id, ns, name, { line - 1, 0 }, { line - 1, -1 })
    return self
end

function M:highlight_range(name, range)
    if range:is_collapsed() then
        pcall(
            vim.hl.range,
            self.id,
            ns,
            name,
            { range:get_row_start() - 1, 0 },
            { range:get_row_end() - 1, -1 }
        )
    else
        pcall(
            vim.hl.range,
            self.id,
            ns,
            name,
            { range:get_row_start() - 1, range:get_col_start() },
            { range:get_row_end() - 1, range:get_col_end() }
        )
    end
    return self
end

function M:clear_highlights()
    vim.api.nvim_buf_clear_namespace(self.id, ns, 0, -1)
    return self
end

function M:is_loaded()
    return vim.api.nvim_buf_is_loaded(self.id)
end

function M:on_focus(cb)
    au({ "BufEnter" }, cb, { buffer = self.id })
    return self
end

function M:on_content_changed(cb)
    au({ "TextChanged", "TextChangedI", "TextChangedP" }, cb, { buffer = self.id })
    return self
end

function M:map(modes, lhs, rhs, options)
    vim.keymap.set(
        modes,
        lhs,
        rhs,
        vim.tbl_extend("force", {
            buffer = self.id,
            noremap = true,
        }, options or {})
    )
    return self
end

return M
