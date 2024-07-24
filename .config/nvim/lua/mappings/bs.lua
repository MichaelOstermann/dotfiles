local expr = require("utils.mappings").expr
local b = require("utils.buffer")

local pairs = {
    { "'", "'" },
    { '"', '"' },
    { "`", "`" },
    { "[", "]" },
    { "(", ")" },
    { "{", "}" },
    { "{ ", " }" },
    { "<", ">" },
}

expr("i", "<bs>", function()
    if b.is_special() then
        return "<bs>"
    end

    if b.has_any_surrounding_chars(pairs) then
        return "<left><del><del>"
    end

    if b.has_surrounding_chars("{", "  }") then
        return "<del><del>"
    end

    if b.has_surrounding_chars("{  ", "}") then
        return "<left><left><del><del>"
    end

    return "<bs>"
end)
