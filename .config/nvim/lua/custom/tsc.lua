local Win = require("ui").Win
local tsc = require("nvim-tsc")

local M = {}

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

            tsc.run({
                on_report = vim.schedule_wrap(function(report)
                    local last_path = nil

                    for _, error in ipairs(report) do
                        if last_path ~= error.path then
                            last_path = error.path
                            win:line():set_data({ path = error.path }):add(error.path, "Directory")
                        end
                        win:line()
                            :set_data({ path = error.path, pos = { error.lnum, error.col - 1 } })
                            :add(error.lnum, "LineNr")
                            :add(":", "LineNr")
                            :add(error.col, "LineNr")
                            :add(" ")
                            :add(error.message[1])
                    end

                    win.spinner:stop()
                    win:render()
                end),
            })
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
