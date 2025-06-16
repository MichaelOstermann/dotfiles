local Tab = require("ui.Tab")
local Input = require("ui.Input")
local List = require("ui.List")
local Float = require("ui.Float")
local Preview = require("ui.Preview")
local Lsp = require("utils.Lsp")
local effect = require("signals.effect")
local batch = require("signals.batch")

return function(options)
    local input = Input.create({
        title = options.title,
        border = "rounded",
        focus = true,
        height = 1,
    })

    local results = List.create({
        border = "rounded",
        top = input.bottom,
        width = function()
            return Float.max_width:get() - 90
        end,
        render = options.render,
    })

    local preview = Preview.create({
        border = "rounded",
        top = input.bottom,
        left = results.right,
        width = 90,
    })

    local tab = Tab.create()

    local pane = {
        input = input,
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

    local refresh_manual = function()
        options.refresh(pane, true)
    end

    local refresh = function()
        options.refresh(pane, false)
    end

    tab:on_mount(function()
        input:open()
        results:open()
        preview:open()

        input:map("n", "r", refresh_manual)
        results:map("n", "r", refresh_manual)
        preview:map("n", "r", refresh_manual)

        input:map("n", "<cr>", open_file)
        results:map("n", "<cr>", open_file)
        results:map("n", "<2-LeftMouse>", open_file)
        preview:map("n", "<cr>", open_file)

        input:map("n", "q", close)
        results:map("n", "q", close)
        preview:map("n", "q", close)

        input:map("n", "gg", function()
            results:go_to_top()
        end)
        input:map("n", "G", function()
            results:go_to_bottom()
        end)
        input:map("n", "<down>", function()
            results:go_to_next()
        end)
        input:map("n", "<up>", function()
            results:go_to_prev()
        end)

        input:map("n", "<tab>", function()
            results:focus()
        end)
        results:map("n", "<tab>", function()
            preview:focus()
        end)
        preview:map("n", "<tab>", function()
            input:focus()
        end)

        input:map("n", "<esc>", function()
            input:focus()
        end)
        results:map("n", "<esc>", function()
            input:focus()
        end)
        preview:map("n", "<esc>", function()
            input:focus()
        end)

        effect(refresh)

        effect(function()
            local current = results.selected:get() or {}
            preview:show_file(current.path, current.range)
        end)
    end)

    return pane
end
