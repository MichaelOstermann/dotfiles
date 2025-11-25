local Float = require("ui.Float")
local Spinner = require("ui.Spinner")
local Line = require("ui.Line")
local signal = require("signals.signal")
local effect = require("signals.effect")

local M = {}

function M.create(options)
    local float = Float.create(vim.tbl_extend("force", {
        height = 1,
    }, options))

    local spinner_content = signal({})

    float.spinner = Spinner.create({
        on_tick = function(message)
            spinner_content:set({ message, "Number" })
        end,
        on_stop = function(message)
            spinner_content:set({})
        end,
    })

    float:on_mount(function()
        effect(function()
            float:set_modifiable(true)
            local line = Line.create(1)
            line:add(options.content, "Keyword")
            local spin_text, spin_hi = unpack(spinner_content:get())
            if spin_text then
                line:add(" "):add(spin_text, spin_hi)
            end
            float:set_lines(1, 1, { line.content })
            for _, highlight in ipairs(line.highlights) do
                float:highlight_range(highlight.name, highlight.range)
            end
            float:set_modifiable(false)
        end)
    end)

    return float
end

return M
