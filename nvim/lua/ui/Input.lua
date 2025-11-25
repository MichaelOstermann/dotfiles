local Float = require("ui.Float")
local signal = require("signals.signal")

local M = {}

function M.create(options)
    local float = Float.create(vim.tbl_extend("force", {
        height = 1,
        margin_left = options.label and #options.label or 0,
    }, options))

    float.content = signal("")

    if options.label then
        float.label = Float.create({
            top = options.top,
            height = 1,
            left = options.left,
            width = #options.label,
        })

        float:on_mount(function()
            float.label:open()
            float.label:set_lines(1, 1, { options.label })
            float.label:highlight_line("Keyword", 1)
            float.label:set_modifiable(false)
            float.label:on_focus(function()
                float:focus()
                float:set_cursor(1, 0)
            end)
        end)
    end

    float:on_mount(function()
        vim.b[float:buf().id].completion = false
        float:on_content_changed(function()
            float:enforce_single_line()
            float.content:set(float:get_lines()[1])
        end)
    end)

    return float
end

return M
