local M = {}
local S = {}

local spinner_tbl = {
    "010010",
    "001100",
    "100101",
    "111010",
    "111101",
    "010111",
    "101011",
    "111000",
    "110011",
    "110101",
}

S.start = function(spinner, message)
    if spinner.is_running then
        return
    end

    spinner.is_running = true

    if spinner.on_start then
        spinner.on_start()
    end

    spinner.timer:start(0, 80, function()
        spinner.offset = spinner.offset + 1
        if spinner.offset > #spinner_tbl then
            spinner.offset = 1
        end

        if spinner.on_tick then
            if message then
                vim.schedule_wrap(spinner.on_tick)(spinner_tbl[spinner.offset] .. " " .. message)
            else
                vim.schedule_wrap(spinner.on_tick)(spinner_tbl[spinner.offset])
            end
        end
    end)
end

S.stop = function(spinner)
    if not spinner.is_running then
        return
    end

    spinner.is_running = false
    spinner.timer:stop()

    if spinner.on_stop then
        spinner.on_stop()
    end
end

M.create = function(options)
    return setmetatable({
        is_running = false,
        offset = 1,
        timer = vim.uv.new_timer(),
        on_start = options.on_start,
        on_stop = options.on_stop,
        on_tick = options.on_tick,
    }, {
        __index = S,
    })
end

return M
