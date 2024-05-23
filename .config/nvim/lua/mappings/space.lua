local expr = require("mappings._utils").expr
local b = require("utils.buffer")

expr("i", "<space>", function()
    local base = " <c-g>u"

    if b.is_inside_string() then return base end
    if b.is_special() then return base end
    if b.has_surrounding_chars("{", "}") then return "  <c-g>u<left>" end

    return base
end)
