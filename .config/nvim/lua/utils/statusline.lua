local computed = require("signals.computed")

local M = {}

local function resolve_highlight(highlights)
    if not highlights then
        return
    end
    if type(highlights) == "string" then
        return highlights
    end
    for hi, enabled in pairs(highlights) do
        if enabled then
            return hi
        end
    end
end

local function highlight(segment)
    local content, highlights = unpack(segment)
    local hi = resolve_highlight(highlights)
    if not hi then
        return content
    end
    return "%#" .. hi .. "#" .. content .. "%*"
end

local function component(fn)
    local component = computed(fn)

    local render = computed(function()
        local segments = vim.tbl_map(function(segment)
            if type(segment) == "table" then
                return highlight(segment)
            else
                return segment
            end
        end, component:get() or {})

        return table.concat(segments, "")
    end)

    local content = computed(function()
        local segments = vim.tbl_map(function(segment)
            if type(segment) == "table" then
                return segment[1]
            else
                return segment
            end
        end, component:get() or {})

        return table.concat(segments, "")
    end)

    local size = computed(function()
        return vim.fn.strdisplaywidth(content:get())
    end)

    return {
        content = render,
        size = size,
    }
end

local function components(components)
    return {
        content = computed(function()
            local result = ""
            for _, c in ipairs(components) do
                local content = c.content:get()
                if content then
                    result = result .. content
                end
            end
            return result
        end),
        size = computed(function()
            local size = 0
            for _, c in ipairs(components) do
                size = size + c.size:get()
            end
            return size
        end),
    }
end

M.component = component
M.components = components

return M
