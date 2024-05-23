local expr = require("mappings._utils").expr
local b = require("utils.buffer")

expr("n", "o", function()
    local row = vim.api.nvim_win_get_cursor(0)[1]
    local level = b.get_indentation_level(row)
    return "o" .. b.get_indentation_string(level)
end)

expr("n", "O", function()
    local row = vim.api.nvim_win_get_cursor(0)[1]
    local level = b.get_indentation_level(row)
    return "O" .. b.get_indentation_string(level)
end)
