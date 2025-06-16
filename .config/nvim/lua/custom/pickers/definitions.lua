local Lsp = require("utils.Lsp")
local batch = require("signals.batch")
local dual_pane = require("custom.pickers.dual_pane")

local win, buf, job

local pane = dual_pane({
    title = "Definitions",
    render = function(line, data)
        if data.type == "directory" then
            line:add(""):add(data.path, "Directory")
        else
            line:add("")
                :add(data.range:get_row_start(), "LineNr")
                :add(":", "LineNr")
                :add(data.range:get_col_end() + 1, "LineNr")
                :add(" ")
                :add(vim.fn.trim(data.text))
        end
    end,
    refresh = function(pane)
        if job then
            job.cancel()
        end

        job = Lsp.request_locations(win, buf, "textDocument/definition", {}, function(list)
            job = nil
            local result = {}
            local last_path
            for _, item in ipairs(list) do
                if last_path ~= item.path then
                    table.insert(result, {
                        type = "directory",
                        path = item.path,
                    })
                end
                table.insert(result, {
                    type = "match",
                    path = item.path,
                    range = item.range,
                    text = item.text,
                })
            end
            batch(function()
                pane.results:go_to_top()
                pane.results.data:set(result)
            end)
        end)
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
