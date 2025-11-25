local filetypes = require("utils.filetypes")
local M = {}

M.format_and_save = function()
    local bufnr = vim.api.nvim_get_current_buf()

    if not vim.tbl_isempty(vim.lsp.get_clients({
        bufnr = bufnr,
        name = "eslint",
    })) then
        vim.cmd("LspEslintFixAll")
        vim.cmd("w")
        return
    end

    require("conform").format({ bufnr = bufnr })
    vim.cmd("w")
end

M.get_node_types_left = function()
    local ok, node = pcall(function()
        local row, col = unpack(vim.api.nvim_win_get_cursor(0))
        return vim.treesitter.get_node({ pos = { row - 1, col - 1 } })
    end)
    local result = {}
    while ok and node do
        table.insert(result, node:type())
        node = node:parent()
    end
    return result
end

M.get_node_types_right = function()
    local ok, node = pcall(function()
        local row, col = unpack(vim.api.nvim_win_get_cursor(0))
        return vim.treesitter.get_node({ pos = { row - 1, col } })
    end)
    local result = {}
    while ok and node do
        table.insert(result, node:type())
        node = node:parent()
    end
    return result
end

M.has_node_type_left = function(pattern)
    local ok, node = pcall(function()
        local row, col = unpack(vim.api.nvim_win_get_cursor(0))
        return vim.treesitter.get_node({ pos = { row - 1, col - 1 } })
    end)
    while ok and node do
        if string.find(node:type(), pattern) then
            return true
        end
        node = node:parent()
    end
    return false
end

M.has_node_type_right = function(pattern)
    local _, node = pcall(function()
        local row, col = unpack(vim.api.nvim_win_get_cursor(0))
        return vim.treesitter.get_node({ pos = { row - 1, col } })
    end)
    while ok and node do
        if string.find(node:type(), pattern) then
            return true
        end
        node = node:parent()
    end
    return false
end

M.find_node_ancestor = function(types)
    local node = vim.treesitter.get_node()

    while node do
        if vim.list_contains(types, node:type()) then
            return node
        end
        node = node:parent()
    end

    return node
end

M.is_jsdoc = function()
    if not M.has_node_type_left("comment") then
        return false
    end

    local line = vim.api.nvim_get_current_line()
    return string.match(line, "^%s*/%*") or string.match(line, "^%s*%*")
end

M.is_special = function()
    return vim.list_contains(filetypes.special_filetypes, vim.bo.filetype)
        or vim.list_contains(filetypes.special_buftypes, vim.bo.buftype)
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
        if M.has_surrounding_chars(left, right) then
            return true
        end
    end
    return false
end

M.get_indentation_level = function(row)
    local level = math.floor(vim.fn.indent(row) / vim.bo.shiftwidth)
    if level ~= 0 then
        return level
    end
    if row == 1 then
        return level
    end
    if unpack(vim.api.nvim_buf_get_lines(0, row - 1, row, false)) ~= "" then
        return 0
    end
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
