local au = require("utils.autocommand")
local signals = require("utils.signals")

local M = {}

local timer

local function stop_timer()
    if not timer then
        return
    end
    vim.fn.timer_stop(timer)
    timer = nil
end

local function disable()
    vim.diagnostic.disable()
    stop_timer()
    signals.diagnostics_enabled:set(false)
end

local function enable()
    stop_timer()

    timer = vim.fn.timer_start(500, function()
        timer = nil
        vim.diagnostic.enable()
        signals.diagnostics_enabled:set(true)
    end)
end

M.reset = function()
    vim.diagnostic.reset()
    vim.cmd("LspRestart")
end

au("InsertEnter", disable)
au("InsertLeave", enable)

return M
