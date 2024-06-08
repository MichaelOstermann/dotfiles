local expr = require("utils.mappings").expr
local b = require("utils.buffer")

local quotes = {
    { "'", "'" },
    { '"', '"' },
    { "`", "`" },
}

local brackets = {
    { "[", "]" },
    { "(", ")" },
    { "{", "}" },
}

local function insert_pair(lhs, rhs)
    return function()
        if b.is_special() then
            return lhs
        end
        return lhs .. rhs .. "<left>"
    end
end

local function skip_pair(lhs, rhs)
    return function()
        if b.is_special() then
            return rhs
        end
        if b.has_surrounding_chars(lhs, rhs) then
            return "<right>"
        end
        return rhs
    end
end

for _, pair in ipairs(quotes) do
    local lhs, rhs = unpack(pair)
    expr("i", lhs, insert_pair(lhs, rhs))
end

for _, pair in ipairs(brackets) do
    local lhs, rhs = unpack(pair)
    expr("i", lhs, insert_pair(lhs, rhs))
    expr("i", rhs, skip_pair(lhs, rhs))
end
