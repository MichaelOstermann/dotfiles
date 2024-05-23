local expr = require("mappings._utils").expr
local b = require("utils.buffer")

expr("n", "cc", function()
    local row = unpack(vim.api.nvim_win_get_cursor(0))
    local level = b.get_indentation_level(row)
    return '"_cc' .. b.get_indentation_string(level)
end)
