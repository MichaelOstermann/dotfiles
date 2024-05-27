local expr = require("mappings._utils").expr
local b = require("utils.buffer")

local types = {
    "type_identifier",
    "property_identifier",
    "identifier",
}

expr("i", "<", function()
    local type = b.get_node_type_left()
    if vim.tbl_contains(types, type) then return "<><left>" end
    return "<"
end)
