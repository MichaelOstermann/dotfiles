local au = require("utils.autocommand")

local M = {}

M.mru_bufs = {}

au({ "BufEnter", "BufWinEnter" }, function(evt)
    local path = vim.api.nvim_buf_get_name(evt.buf)
    local buftype = vim.api.nvim_get_option_value("buftype", { buf = evt.buf })
    if path ~= "" and buftype == "" then
        local rel_path = vim.fs.relpath(vim.fn.getcwd(), path)
        M.mru_bufs = vim.tbl_filter(function(it)
            return it ~= rel_path
        end, M.mru_bufs)
        table.insert(M.mru_bufs, 1, rel_path)
    end
end)

return M
