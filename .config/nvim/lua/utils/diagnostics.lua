local M = {}

local function stop_timer(buf)
    if not vim.b[buf].diagnostics_timer then return end
    vim.fn.timer_stop(vim.b[buf].diagnostics_timer)
    vim.b[buf].diagnostics_timer = nil
end

M.disable = function(buf)
    vim.diagnostic.disable(buf)
    stop_timer(buf)
end

M.enable = function(buf)
    stop_timer(buf)

    vim.b[buf].diagnostics_timer = vim.fn.timer_start(500, function()
        if not vim.api.nvim_buf_is_loaded(buf) then return end
        vim.b[buf].diagnostics_timer = nil
        vim.diagnostic.enable(buf)
    end)
end

M.reset = function()
    vim.diagnostic.reset()
    vim.cmd("LspRestart")
end

return M
