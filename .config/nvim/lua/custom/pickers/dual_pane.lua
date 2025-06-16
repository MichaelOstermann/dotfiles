local Tab = require("ui.Tab")
local List = require("ui.List")
local Float = require("ui.Float")
local Preview = require("ui.Preview")
local Lsp = require("utils.Lsp")
local effect = require("signals.effect")
local batch = require("signals.batch")

return function(options)
    local results = List.create({
        title = options.title,
        border = "rounded",
        focus = true,
        width = function()
            return Float.max_width:get() - 90
        end,
        render = options.render,
    })

    local preview = Preview.create({
        border = "rounded",
        left = results.right,
        width = 90,
    })

    local tab = Tab.create()

    local pane = {
        results = results,
        preview = preview,
        tab = tab,
    }

    local open_file = function()
        local selected = results.selected:get() or {}
        tab:close_and_edit(selected.path, selected.range)
    end

    local close = function()
        tab:close()
    end

    local refresh = function()
        options.refresh(pane)
    end

    tab:on_mount(function()
        results:open()
        preview:open()

        results:map("n", "r", refresh)
        preview:map("n", "r", refresh)

        results:map("n", "<cr>", open_file)
        results:map("n", "<2-LeftMouse>", open_file)
        preview:map("n", "<cr>", open_file)

        results:map("n", "q", close)
        preview:map("n", "q", close)

        results:map("n", "<tab>", function()
            preview:focus()
        end)
        preview:map("n", "<tab>", function()
            results:focus()
        end)
        preview:map("n", "<esc>", function()
            results:focus()
        end)

        effect(refresh)

        effect(function()
            local current = results.selected:get() or {}
            preview:show_file(current.path, current.range)
        end)
    end)

    return pane
end
