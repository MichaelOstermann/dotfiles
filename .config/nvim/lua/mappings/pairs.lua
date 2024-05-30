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
}

local function insert_pair(left, right)
    return function()
        if b.is_special() then return left end
        return left .. right .. "<left>"
    end
end

local function skip_pair(right)
    return function()
        if b.is_special() then return right end
        if b.has_surrounding_chars("", right) then return "<right>" end
        return right
    end
end

for _, pair in ipairs(quotes) do
    local left, right = unpack(pair)
    expr("i", left, insert_pair(left, right))
end

for _, pair in ipairs(brackets) do
    local left, right = unpack(pair)
    expr("i", left, insert_pair(left, right))
    expr("i", right, skip_pair(right))
end
