local Float = require("ui.Float")
local signal = require("signals.signal")

local M = {}

function M.create(options)
    local float = Float.create(options)

    float.content = signal("")

    float:on_mount(function()
        float:on_content_changed(function()
            float:enforce_single_line()
            float.content:set(float:get_lines()[1])
        end)
    end)

    return float
end

return M
