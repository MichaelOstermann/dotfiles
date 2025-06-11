local M = {}
local L = {}

L.add = function(line, text, highlight)
    text = tostring(text)
    local length = #text

    if length == 0 then
        return line
    end

    if highlight then
        table.insert(line.highlights, {
            highlight,
            line.length,
            length,
        })
    end

    line.content = line.content .. text
    line.length = line.length + length

    return line
end

L.set_data = function(line, data)
    line.data = vim.tbl_extend("force", line.data, data)
    return line
end

M.create = function()
    return setmetatable({
        length = 0,
        content = "",
        highlights = {},
        data = {},
    }, {
        __index = L,
    })
end

return M
