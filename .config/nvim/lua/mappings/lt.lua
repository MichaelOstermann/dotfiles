local expr = require("utils.mappings").expr
local b = require("utils.buffer")

local types = {
    "type_identifier",
    "property_identifier",
    "identifier",
}

expr("i", "<", function()
    local type = b.get_node_type_left()
    if vim.list_contains(types, type) then
        return "<><left>"
    end
    return "<"
end)
