local filetypes = require("utils.filetypes")
local M = {}

local function has_eslint()
    return not vim.tbl_isempty(vim.lsp.get_active_clients({
        bufnr = vim.api.nvim_get_current_buf(),
        name = "eslint",
    }))
end

M.format_and_save = function()
    if has_eslint() then
        vim.cmd("EslintFixAll")
    else
        vim.lsp.buf.format()
    end
    vim.cmd("w")
end

M.get_node_type_left = function()
    local _, node = pcall(function()
        local row, col = unpack(vim.api.nvim_win_get_cursor(0))
        return vim.treesitter.get_node({ pos = { row - 1, col - 1 } }):type()
    end)
    return node or ""
end

M.get_node_type_right = function()
    local _, node = pcall(function()
        local row, col = unpack(vim.api.nvim_win_get_cursor(0))
        return vim.treesitter.get_node({ pos = { row - 1, col } }):type()
    end)
    return node or ""
end

M.is_special = function()
    return vim.tbl_contains(filetypes.special_filetypes, vim.bo.filetype)
        or vim.tbl_contains(filetypes.special_buftypes, vim.bo.buftype)
end

M.get_surrounding_chars = function(left, right)
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    local line = vim.api.nvim_get_current_line()
    return line:sub(col + 1 - left, col + right)
end

M.has_surrounding_chars = function(left, right)
    return M.get_surrounding_chars(#left, #right) == left .. right
end

M.has_any_surrounding_chars = function(table)
    for _, pair in ipairs(table) do
        local left, right = unpack(pair)
        if M.has_surrounding_chars(left, right) then return true end
    end
    return false
end

M.get_indentation_level = function(row)
    local level = math.floor(vim.fn.indent(row) / vim.bo.shiftwidth)
    if level ~= 0 then return level end
    if row == 1 then return level end
    if unpack(vim.api.nvim_buf_get_lines(0, row - 1, row, false)) ~= "" then return 0 end
    return M.get_indentation_level(row - 1)
end

M.get_current_indentation_level = function()
    local row = vim.api.nvim_win_get_cursor(0)[1]
    return M.get_indentation_level(row)
end

M.get_indentation_string = function(level)
    return string.rep(" ", level * vim.bo.shiftwidth)
end

return M
