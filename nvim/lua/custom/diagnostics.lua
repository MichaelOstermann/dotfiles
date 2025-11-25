local au = require("utils.autocommand")
local signals = require("utils.signals")

local M = {}

local timer

local function stop_timer(buf)
    if not vim.b[buf].diagnostics_timer then
        return
    end
    vim.fn.timer_stop(vim.b[buf].diagnostics_timer)
    vim.b[buf].diagnostics_timer = nil
end

local function disable(args)
    local buf = args.buf
    vim.diagnostic.enable(false, {
        bufnr = buf,
    })
    stop_timer(buf)
    if signals.buffers[buf] then
        signals.buffers[buf].diagnostics_enabled:set(false)
    end
end

local function enable(args)
    local buf = args.buf
    stop_timer(buf)

    vim.b[buf].diagnostics_timer = vim.fn.timer_start(500, function()
        if vim.api.nvim_buf_is_loaded(buf) then
            vim.b[buf].diagnostics_timer = nil
            vim.diagnostic.enable(true, {
                bufnr = buf,
            })
        end

        if signals.buffers[buf] then
            signals.buffers[buf].diagnostics_enabled:set(true)
        end
    end)
end

au("InsertEnter", disable)
au("InsertLeave", enable)

return M
