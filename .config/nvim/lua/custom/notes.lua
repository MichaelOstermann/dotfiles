local signals = require("utils.signals")
local signal = require("signals.signal")
local effect = require("signals.effect")
local computed = require("signals.computed")

local M = {}

local base_path = "~/Library/Mobile Documents/com~apple~CloudDocs/Notes/Dev"
local overlay_win = signal(nil)
local editor_win = signal(nil)

local overlay_win_config = computed(function()
    return {
        border = "none",
        style = "minimal",
        focusable = false,
        relative = "editor",
        width = signals.width:get(),
        height = signals.height:get() - 2,
        row = 0,
        col = 0,
    }
end)

local editor_win_config = computed(function()
    local width = signals.width:get()
    local win_width = math.min(math.ceil(width * 0.9), 120)
    local win_col = math.ceil((width - win_width) * 0.5)

    return {
        border = "none",
        relative = "editor",
        style = "minimal",
        width = win_width,
        col = win_col,
        height = signals.height:get() - 2,
        row = 0,
    }
end)

effect(function()
    if overlay_win:is(nil) then
        return
    end
    vim.api.nvim_win_set_config(overlay_win:get(), overlay_win_config:get())
end)

effect(function()
    if editor_win:is(nil) then
        return
    end
    vim.api.nvim_win_set_config(editor_win:get(), editor_win_config:get())
end)

local function create_overlay_win()
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")

    local win = vim.api.nvim_open_win(buf, false, overlay_win_config:get())
    overlay_win:set(win)
end

local function create_editor_win()
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")

    local win = vim.api.nvim_open_win(buf, true, editor_win_config:get())
    editor_win:set(win)
    vim.opt_local.signcolumn = "no"

    local name = vim.fn.fnamemodify(vim.uv.cwd(), ":t")
    local path = base_path .. "/" .. name .. ".md"
    vim.api.nvim_command("edit " .. path)
end

M.is_open = function()
    return not editor_win:is(nil)
end

M.toggle = function()
    if M.is_open() then
        M.close()
    else
        M.open()
    end
end

M.open = function()
    create_overlay_win()
    create_editor_win()
end

M.close = function()
    local a = editor_win:get()
    local b = overlay_win:get()

    if vim.api.nvim_win_is_valid(a) then
        vim.api.nvim_win_close(a, true)
    end
    if vim.api.nvim_win_is_valid(b) then
        vim.api.nvim_win_close(b, true)
    end

    editor_win:set(nil)
    overlay_win:set(nil)
end

vim.api.nvim_create_autocmd("WinClosed", {
    callback = function(args)
        local win = tonumber(args.file)
        if editor_win:is(win) then
            M.close()
        end
        if overlay_win:is(win) then
            M.close()
        end
    end,
})

return M
