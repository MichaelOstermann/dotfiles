local expr = require("utils.mappings").expr
local b = require("utils.buffer")

expr("i", "$", function()
    if b.has_node_type_left("template_string") then
        return "${}<left>"
    end
    return "$"
end)
