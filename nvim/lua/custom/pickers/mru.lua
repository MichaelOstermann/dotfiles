local Lsp = require("utils.lsp")
local batch = require("signals.batch")
local dual_pane = require("custom.pickers.dual_pane")
local mru = require("custom.mru")

local pane = dual_pane({
    title = "MRU",
    render = function(line, data)
        line:add(""):add(data.path)
    end,
    refresh = function(pane)
        local result = {}
        for _, path in ipairs(mru.mru_bufs) do
            table.insert(result, {
                type = "directory",
                path = path,
            })
        end
        batch(function()
            pane.results:go_to_top()
            pane.results.data:set(result)
        end)
    end,
})

pane.tab:on_open(function()
    local result = {}
    for _, path in ipairs(mru.mru_bufs) do
        table.insert(result, {
            path = path,
        })
    end
    batch(function()
        pane.results:go_to_top()
        pane.results.data:set(result)
    end)
end)

return {
    open = function()
        pane.tab:open()
    end,
}
