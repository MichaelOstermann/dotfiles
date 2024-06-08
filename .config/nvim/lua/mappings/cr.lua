local expr = require("mappings._utils").expr
local b = require("utils.buffer")

local pairs = {
    { "{", "}" },
    { "[", "]" },
    { "(", ")" },
    { ">", "<" },
    { "<", ">" },
}

expr("i", "<cr>", function()
    local level = b.get_current_indentation_level()
    local expand = "<cr><cr>" .. b.get_indentation_string(level) .. "<up>" .. b.get_indentation_string(level + 1)

    if b.has_any_surrounding_chars(pairs) then
        return expand
    end

    if b.has_surrounding_chars("{ ", " }") then
        return "<right><bs><bs>" .. expand
    end

    if b.has_surrounding_chars("{", "  }") then
        return "<right><right><bs><bs>" .. expand
    end

    if b.has_surrounding_chars("{  ", "}") then
        return "<bs><bs>" .. expand
    end

    return "<cr>" .. b.get_indentation_string(level)
end)
