local expr = require("mappings._utils").expr
local b = require("utils.buffer")

expr("i", "<space>", function()
    if b.is_special() then
        return " <c-g>u"
    end

    if b.has_surrounding_chars("{", "}") then
        return "  <c-g>u<left>"
    end

    return " <c-g>u"
end)
