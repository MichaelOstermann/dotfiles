local Title = require("ui.Title")
local Input = require("ui.Input")
local Tab = require("ui.Tab")
local List = require("ui.List")
local Float = require("ui.Float")
local Preview = require("ui.Preview")
local Lsp = require("utils.lsp")
local effect = require("signals.effect")
local batch = require("signals.batch")
local fzy = require("fzy")

local preview_width = 90

return function(options)
    local title = Title.create({
        content = options.title,
        width = function()
            return Float.max_width:get() - preview_width
        end,
    })

    local prompt = Input.create({
        top = 1,
        label = "Filter ",
        focus = true,
        width = function()
            return Float.max_width:get() - preview_width
        end,
    })

    local results = List.create({
        top = prompt.bottom,
        filter = function(data)
            local filter = prompt.content:get()
            if filter and filter ~= "" then
                return vim.tbl_filter(function(it)
                    return fzy.has_match(filter, it.path)
                end, data)
            else
                return data
            end
        end,
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
        prompt = prompt,
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
        prompt:open()
        results:open()
        preview:open()

        results:on_focus(function()
            vim.cmd.stopinsert()
        end)

        preview:on_focus(function()
            vim.cmd.stopinsert()
        end)

        prompt:map("n", "r", refresh)
        results:map("n", "r", refresh)
        preview:map("n", "r", refresh)

        prompt:map({ "n", "i" }, "<cr>", open_file)
        results:map("n", "<cr>", open_file)
        results:map("n", "<2-LeftMouse>", open_file)
        preview:map("n", "<cr>", open_file)

        prompt:map("n", "q", close)
        results:map("n", "q", close)
        preview:map("n", "q", close)

        prompt:map("n", "gg", function()
            results:go_to_top()
        end)
        prompt:map("n", "G", function()
            results:go_to_bottom()
        end)
        prompt:map({ "n", "i" }, "<down>", function()
            results:go_to_next()
        end)
        prompt:map({ "n", "i" }, "<up>", function()
            results:go_to_prev()
        end)

        prompt:map({ "n", "i" }, "<tab>", function()
            results:focus()
        end)
        results:map("n", "<tab>", function()
            preview:focus()
        end)
        preview:map("n", "<tab>", function()
            prompt:focus()
        end)

        prompt:map({ "n", "i" }, "<s-tab>", function()
            preview:focus()
        end)
        results:map("n", "<s-tab>", function()
            prompt:focus()
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
