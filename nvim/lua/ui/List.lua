local Float = require("ui.Float")
local Line = require("ui.Line")
local signal = require("signals.signal")
local computed = require("signals.computed")
local effect = require("signals.effect")

local M = {}

function M.create(options)
    local float = Float.create(options)

    float.data = signal({})

    float.scroll_top = signal(1)

    float.count = computed(function()
        return #float.data:get()
    end)

    float.empty_lines = computed(function()
        local lines = {}
        for i = 1, float.count:get(), 1 do
            table.insert(lines, "")
        end
        return lines
    end)

    float.selected = computed(function()
        local data = float.data:get()
        local row = float.row:get()
        return data[row]
    end)

    float:on_mount(function()
        float:set_modifiable(false)

        float:on_scroll(function(scrolltop)
            float.scroll_top:set(scrolltop)
        end)

        effect(function()
            local data = float.data:get()
            local count = float.count:get()

            float:set_modifiable(true)

            -- Replace everything with empty lines, not the most efficient way of doing this,
            -- but displaying 10s of thousands of entries feels pretty snappy still.
            float:set_lines(1, -1, float.empty_lines:get())

            -- Render visible lines.
            if count > 0 then
                local start_pos = math.min(float.scroll_top:get(), count)
                local end_pos = math.min(start_pos + float.height:get(), count)

                local content = {}
                local highlights = {}

                for row = start_pos, end_pos, 1 do
                    local line = Line.create(row)
                    options.render(line, data[row], row, float)
                    table.insert(content, line.content)
                    for _, highlight in ipairs(line.highlights) do
                        table.insert(highlights, highlight)
                    end
                end

                float:set_lines(start_pos, end_pos, content)

                for _, highlight in ipairs(highlights) do
                    float:highlight_range(highlight.name, highlight.range)
                end
            end

            float:set_modifiable(false)
            float:set_cursorline(count > 0)
        end)
    end)

    return float
end

return M
