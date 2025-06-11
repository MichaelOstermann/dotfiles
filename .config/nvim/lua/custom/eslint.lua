local Win = require("ui").Win

local M = {}

local severities = {
    "DiagnosticSignWarn",
    "DiagnosticSignError",
}

local function is_executable(cmd)
    return cmd and vim.fn.executable(cmd) == 1 or false
end

local function find_eslint_bin()
    local path = vim.fn.findfile("node_modules/.bin/eslint", ".;")
    if path ~= "" then
        return path
    end
    return "eslint"
end

local win = Win.create({
    actions = {
        open = function(win)
            local data = win:current_line_data()
            win:close()
            vim.cmd("edit " .. vim.fn.fnameescape(data.path))
            if data.pos then
                vim.api.nvim_win_set_cursor(0, data.pos)
            end
        end,
        refresh = function(win)
            win:clear()
            win.spinner:start()

            local bin = find_eslint_bin()
            if not is_executable(bin) then
                win.spinner:stop()
                return
            end

            vim.system(
                { bin, ".", "--format", "json" },
                {
                    text = true,
                    env = { NVIM = "", VIM = "" },
                    cwd = vim.uv.cwd(),
                },
                vim.schedule_wrap(function(obj)
                    local last_path = nil
                    local ok, data = pcall(vim.json.decode, obj.stdout, { luanil = { object = true, array = true } })

                    if not ok then
                        win.spinner:stop()
                        return
                    end

                    for _, entry in ipairs(data or {}) do
                        for _, msg in ipairs(entry.messages or {}) do
                            if last_path ~= entry.filePath then
                                last_path = entry.filePath
                                win:line()
                                    :set_data({ path = entry.filePath })
                                    :add(vim.fs.relpath(vim.fn.getcwd(), entry.filePath), "Directory")
                            end

                            local pos = nil
                            if msg.line and msg.column then
                                pos = { msg.line, msg.column - 1 }
                            elseif msg.line then
                                pos = { msg.line, 0 }
                            elseif msg.column then
                                pos = { 1, msg.column - 1 }
                            end

                            win:line()
                                :set_data({ path = entry.filePath, pos = pos })
                                :add("▎", severities[msg.severity])
                                :add(msg.line and msg.line or 1, "LineNr")
                                :add(":", "LineNr")
                                :add(msg.column and msg.column or 1, "LineNr")
                                :add(" ")
                                :add(msg.message)
                                :add(" ")
                                :add(msg.ruleId, "Keyword")
                        end
                    end

                    win.spinner:stop()
                    win:render()
                end)
            )
        end,
    },
    mappings = {
        ["<cr>"] = "open",
        r = "refresh",
    },
    on_first_open = function(win)
        win.actions.refresh()
    end,
})

M.run = function()
    win:open()
end

return M
