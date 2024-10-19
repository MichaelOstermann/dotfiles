local au = require("utils.autocommand")
local signals = require("utils.signals")
local signal = require("signals.signal")
local effect = require("signals.effect")
local statusline = require("utils.statusline")

local wins = {}

local function detach_winbar(win)
    if not wins[win] then
        return
    end
    wins[win]:dispose()
    wins[win] = nil
    vim.api.nvim_win_set_option(win, "winbar", "")
end

local function attach_winbar(win, buf)
    detach_winbar(win)

    local b = signals.buffers[buf]

    local winbar = statusline.components({
        statusline.component(function()
            local diagnostics_enabled = b.diagnostics_enabled:get()
            return {
                {
                    b.name:get(),
                    {
                        DiagnosticError = diagnostics_enabled and b.severity:is(vim.diagnostic.severity.ERROR),
                        DiagnosticWarn = diagnostics_enabled and b.severity:is(vim.diagnostic.severity.WARN),
                    },
                },
            }
        end),
        statusline.component(function()
            if not b.modified:get() then
                return
            end
            return { { " ●", "WarningMsg" } }
        end),
    })

    wins[win] = effect(function()
        vim.api.nvim_win_set_option(win, "winbar", winbar.content:get())
    end)
end

local function should_show_winbar(buf)
    return signals.buffers[buf]
        -- Ignore floating windows
        and not vim.api.nvim_win_get_config(0).zindex
end

au({ "BufWinEnter", "WinNew" }, function()
    local win = vim.api.nvim_get_current_win()
    local buf = vim.api.nvim_get_current_buf()

    if should_show_winbar(buf) then
        attach_winbar(win, buf)
    else
        detach_winbar(win)
    end
end)

au("WinClosed", function(args)
    local win = tonumber(args.match)
    detach_winbar(win)
end)
