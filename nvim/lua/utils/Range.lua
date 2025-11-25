local M = {}
M.__index = M

function M.of(range)
    return setmetatable(range, M)
end

function M.empty()
    return M.of({
        focus = { 1, 0 },
        anchor = { 1, 0 },
    })
end

function M:is_collapsed()
    return self.focus[1] == self.anchor[1] and self.focus[2] == self.anchor[2]
end

function M:is_backwards()
    return self.focus[1] < self.anchor[1] or self.focus[2] < self.anchor[2]
end

function M:get_row_start()
    return self:is_backwards() and self.focus[1] or self.anchor[1]
end

function M:get_row_end()
    return self:is_backwards() and self.anchor[1] or self.focus[1]
end

function M:get_col_start()
    return self:is_backwards() and self.focus[2] or self.anchor[2]
end

function M:get_col_end()
    return self:is_backwards() and self.anchor[2] or self.focus[2]
end

function M:set_rows(row)
    self.focus[1] = row
    self.anchor[1] = row
    return self
end

function M:set_cols(col)
    self.focus[2] = col
    self.anchor[2] = col
    return self
end

function M:set_anchor_row(row)
    self.anchor[1] = row
    return self
end

function M:set_focus_row(row)
    self.focus[1] = row
    return self
end

function M:set_anchor_col(col)
    self.anchor[2] = col
    return self
end

function M:set_focus_col(col)
    self.focus[2] = col
    return self
end

function M:shift_anchor_col(shift)
    self.anchor[2] = self.anchor[2] + shift
    return self
end

function M:shift_focus_col(shift)
    self.focus[2] = self.focus[2] + shift
    return self
end

return M
