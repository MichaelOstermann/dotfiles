local Title = require("ui.Title")
local Tab = require("ui.Tab")
local List = require("ui.List")
local Float = require("ui.Float")
local Preview = require("ui.Preview")
local Lsp = require("utils.Lsp")
local effect = require("signals.effect")
local batch = require("signals.batch")

local preview_width = 90

return function(options)
    local title = Title.create({
        content = options.title,
        width = function()
            return Float.max_width:get() - preview_width
        end,
    })

    local results = List.create({
        focus = true,
        top = title.bottom,
        width = function()
            return Float.max_width:get() - preview_width
        end,
        render = options.render,
    })

    local preview = Preview.create({
        left = function()
            return results.right:get() + 1
        end,
        width = preview_width - 1,
    })

    local tab = Tab.create()

    local pane = {
        title = title,
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
        title:open()
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

        results:map("n", "<s-tab>", function()
            preview:focus()
        end)
        preview:map("n", "<s-tab>", function()
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
