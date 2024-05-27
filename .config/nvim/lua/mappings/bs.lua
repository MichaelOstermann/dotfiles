local expr = require("mappings._utils").expr
local b = require("utils.buffer")

local quotes = {
    {"'", "'"},
    {'"', '"'},
    {"`", "`"},
}

local brackets = {
    {"[", "]"},
    {"(", ")"},
    {"{", "}"},
    {"{ ", " }"},
}

expr("i", "<bs>", function()
    if b.is_special() then return "<bs>" end
    if b.has_any_surrounding_chars(quotes) then return "<left><del><del>" end

    if b.is_inside_string() then return "<bs>" end
    if b.has_any_surrounding_chars(brackets) then return "<left><del><del>" end
    if b.has_surrounding_chars("{", "  }") then return "<del><del>" end
    if b.has_surrounding_chars("{  ", "}") then return "<left><left><del><del>" end

    return "<bs>"
end)
