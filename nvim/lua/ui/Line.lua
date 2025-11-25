local Range = require("utils.Range")

local M = {}
M.__index = M

function M.create(row)
    return setmetatable({
        row = row,
        length = 0,
        content = "",
        highlights = {},
    }, M)
end

function M:add(text, highlight)
    text = tostring(text)

    local length = #text

    if length == 0 then
        return self
    end

    local range = Range.empty():set_rows(self.row):set_cols(self.length):shift_focus_col(length)

    if highlight then
        local prev_highlight = self.highlights[#self.highlights]
        if
            prev_highlight
            and prev_highlight.name == highlight
            and prev_highlight.range:get_col_end() == range:get_col_start()
        then
            prev_highlight.range:shift_focus_col(length)
        else
            table.insert(self.highlights, { name = highlight, range = range })
        end
    end

    self.content = self.content .. text
    self.length = range:get_col_end()

    return self
end

return M
