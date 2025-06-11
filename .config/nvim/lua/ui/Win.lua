local Line = require("ui.Line")
local Spinner = require("ui.Spinner")

local M = {}
local W = {}

local ns = vim.api.nvim_create_namespace("")

local default_actions = {
    quit = function(win)
        win:close()
    end,
}

local default_mappings = {
    q = "quit",
}

W.open = function(win)
    if win.is_open then
        return
    end

    win.prev_win = vim.api.nvim_get_current_win()

    vim.api.nvim_win_set_config(win.win, {
        hide = false,
        focusable = true,
    })

    vim.api.nvim_set_current_win(win.win)

    win.is_open = true

    if win.on_first_open then
        win.on_first_open(win)
        win.on_first_open = nil
    end
end

W.close = function(win)
    if not win.is_open then
        return
    end
    vim.api.nvim_win_set_config(win.win, {
        hide = true,
        focusable = false,
    })
    vim.api.nvim_set_current_win(win.prev_win)
    win.prev_win = nil
    win.is_open = false
end

W.render = function(win)
    vim.api.nvim_set_option_value("modifiable", true, { buf = win.buf })

    -- Extract lines and apply them
    local lines = {}
    for _, line in ipairs(win.lines) do
        table.insert(lines, line.content)
    end
    vim.api.nvim_buf_set_lines(win.buf, 0, -1, false, lines)

    -- Apply highlights
    for row, line in ipairs(win.lines) do
        for _, highlight in ipairs(line.highlights) do
            local name, start, size = unpack(highlight)
            vim.api.nvim_buf_add_highlight(win.buf, ns, name, row - 1, start, start + size)
        end
    end

    vim.api.nvim_set_option_value("modifiable", false, { buf = win.buf })
    return win
end

W.clear_lines = function(win)
    win.lines = {}
end

W.clear = function(win)
    win.lines = {}
    win:render()
end

W.line = function(win)
    local line = Line.create()
    table.insert(win.lines, line)
    return line
end

W.current_line_data = function(win)
    local row, col = unpack(vim.api.nvim_win_get_cursor(win.win))
    local line = win.lines[row]
    return line.data
end

M.create = function(options)
    local win = setmetatable({
        win = nil,
        buf = nil,
        is_open = false,
        prev_win = nil,
        actions = {},
        lines = {},
        on_first_open = options and options.on_first_open,
    }, {
        __index = W,
    })

    -- Create buffer
    win.buf = vim.api.nvim_create_buf(false, true)

    -- Create window
    win.win = vim.api.nvim_open_win(win.buf, false, {
        relative = "editor",
        width = vim.api.nvim_get_option("columns"),
        height = vim.api.nvim_get_option("lines"),
        row = 0,
        col = 0,
        style = "minimal",
        border = "rounded",
        focusable = false,
        hide = true,
    })

    -- Setup spinner
    win.spinner = Spinner.create({
        on_tick = function(message)
            vim.api.nvim_win_set_config(win.win, {
                title = message,
            })
        end,
        on_stop = function(message)
            vim.api.nvim_win_set_config(win.win, {
                title = "",
            })
        end,
    })

    -- Buffer options
    vim.api.nvim_set_option_value("modifiable", false, { buf = win.buf })
    vim.api.nvim_set_option_value("filetype", "Custom", { buf = win.buf })

    -- Window options
    vim.api.nvim_set_option_value("number", true, { win = win.win })
    vim.api.nvim_set_option_value("cursorline", true, { win = win.win })

    -- Setup actions
    for key, action in pairs(vim.tbl_extend("force", default_actions, options and options.actions or {})) do
        win.actions[key] = function()
            return action(win)
        end
    end

    -- Setup mappings
    for lhs, rhs in pairs(vim.tbl_extend("force", default_mappings, options and options.mappings or {})) do
        vim.keymap.set("n", lhs, win.actions[rhs], {
            buffer = win.buf,
            noremap = true,
        })
    end

    return win
end

return M
