local au = require("utils.autocommand")
local signal = require("signals.signal")
local batch = require("signals.batch")
local computed = require("signals.computed")

local M = {}

M.diagnostics = signal({})
M.diagnostics_enabled = signal(true)
M.width = signal(vim.o.columns)
M.height = signal(vim.o.lines)
M.mode = signal(vim.api.nvim_get_mode().mode)
M.buf = signal(nil)
M.row = signal(0)
M.col = signal(0)
M.lines = signal(0)
M.signature = signal(nil)

M.buf_diagnostics = computed(function()
    return vim.tbl_filter(function(diagnostic)
        return diagnostic.bufnr == M.buf:get()
    end, M.diagnostics:get())
end)

M.row_diagnostics = computed(function()
    local row = M.row:get() - 1
    return vim.tbl_filter(function(diagnostic)
        return diagnostic.lnum <= row and diagnostic.end_lnum >= row
    end, M.buf_diagnostics:get())
end)

M.col_diagnostics = computed(function()
    local col = M.col:get()
    return vim.tbl_filter(function(diagnostic)
        return diagnostic.col <= col and diagnostic.end_col >= col
    end, M.row_diagnostics:get())
end)

M.diagnostic = computed(function()
    local row_diagnostics = M.row_diagnostics:get()
    if #row_diagnostics == 1 then
        return row_diagnostics[1]
    end
    return M.col_diagnostics:get()[1]
end)

au({ "CursorMoved", "CursorMovedI" }, function()
    local pos = vim.api.nvim_win_get_cursor(0)
    M.row:set(pos[1])
    M.col:set(pos[2])
end)

au("BufEnter", function(args)
    if vim.api.nvim_buf_get_name(args.buf) ~= "" then
        M.buf:set(vim.api.nvim_get_current_buf())
    end
end)

au("VimResized", function()
    M.width:set(vim.o.columns)
    M.height:set(vim.o.lines)
end)

au({
    "BufEnter",
    "TextChanged",
    "TextChangedI",
    "TextChangedP",
    "BufWritePost",
    "FileChangedShellPost",
}, function()
    M.lines:set(vim.api.nvim_buf_line_count(0))
end)

au("DiagnosticChanged", function()
    M.diagnostics:set(vim.diagnostic.get(nil))
end)

au("ModeChanged", function()
    M.mode:set(vim.api.nvim_get_mode().mode)
end)

local function get_buf_name(buf)
    return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":.")
end

local function get_buf_is_modified(buf)
    return vim.api.nvim_buf_get_option(buf, "modified")
end

M.buffers = {}

au("BufReadPost", function(args)
    local buf = args.buf
    local signals = {}

    signals.name = signal(get_buf_name(buf))
    signals.modified = signal(get_buf_is_modified(buf))
    signals.diagnostics = computed(function()
        return vim.tbl_filter(function(diagnostic)
            return diagnostic.bufnr == buf
        end, M.diagnostics:get())
    end)
    signals.severity = computed(function()
        local diagnostic = signals.diagnostics:get()[1]
        return diagnostic and diagnostic.severity
    end)

    au("BufFilePost", function()
        signals.name:set(get_buf_name(buf))
    end, { buffer = buf })

    au("BufModifiedSet", function()
        signals.modified:set(get_buf_is_modified(buf))
    end, { buffer = buf })

    au("BufWipeout", function()
        M.buffers[buf] = nil
    end, { buffer = buf })

    M.buffers[buf] = signals
end)

return M
