local Lsp = require("utils.Lsp")
local Range = require("utils.Range")
local tsc = require("nvim-tsc")
local batch = require("signals.batch")
local dual_pane = require("custom.pickers.dual_pane")

local task

local pane = dual_pane({
    title = "TSC",
    render = function(line, data)
        if data.type == "directory" then
            line:add(" "):add(data.path, "Directory")
        else
            line:add(" ")
                :add(data.range:get_row_start(), "LineNr")
                :add(":", "LineNr")
                :add(data.range:get_col_start() + 1, "LineNr")
                :add(" ")
                :add(data.message)
        end
    end,
    refresh = function(pane)
        if task then
            tsc.stop(task)
        end

        pane.title.spinner:start()

        task = tsc.run({
            on_report = vim.schedule_wrap(function(report)
                pane.title.spinner:stop()
                task = nil
                local last_path = nil
                local result = {}

                for _, error in ipairs(report) do
                    if last_path ~= error.path then
                        last_path = error.path
                        table.insert(result, { type = "directory", path = error.path })
                    end
                    table.insert(result, {
                        type = "error",
                        path = error.path,
                        message = error.message[1],
                        range = Range.empty():set_rows(error.lnum):set_cols(error.col - 1),
                    })
                end

                batch(function()
                    pane.results:go_to_top()
                    pane.results.data:set(result)
                end)
            end),
        })
    end,
})

pane.tab:on_before_open(function()
    win = vim.api.nvim_get_current_win()
    buf = vim.api.nvim_get_current_buf()
end)

return {
    open = function()
        pane.tab:open()
    end,
}
