local os = require("os")
local batch_wrap = require("signals.batch_wrap")
local signal = require("signals.signal")
local computed = require("signals.computed")
local effect = require("signals.effect")

local M = {}

local timer

M.type = signal(nil)
M.start_time = signal(nil)
M.duration = signal(nil)
M.current_time = signal(nil)
M.is_running = computed(function()
    return M.type:get() ~= nil
end)

local time_left = computed(function()
    if M.is_running:is(false) then
        return 0
    end
    return math.max(0, (M.start_time:get() + M.duration:get()) - M.current_time:get())
end)

M.time_left = computed(function()
    local seconds = time_left:get()
    return string.format("%02d:%02d", math.floor(seconds / 60), seconds % 60)
end)

local function tick()
    M.current_time:set(os.time())
end

local function end_clock()
    if not timer then
        return
    end
    timer:stop()
    timer:close()
    timer = nil
end

local function start_clock()
    end_clock()
    tick()
    timer = vim.uv.new_timer()
    timer:start(0, 100, vim.schedule_wrap(tick))
end

effect(function()
    if M.is_running:is(false) then
        return
    end
    if time_left:get() > 0 then
        return
    end

    if M.type:is("session") then
        M.start_break((M.duration:get() / 60) / 3)
    elseif M.type:is("break") then
        M.cancel()
    end
end)

M.start_session = batch_wrap(function(minutes)
    M.type:set("session")
    M.start_time:set(os.time())
    M.duration:set((minutes or 45) * 60)
    start_clock()
end)

M.start_break = batch_wrap(function(minutes)
    M.type:set("break")
    M.start_time:set(os.time())
    M.duration:set((minutes or 15) * 60)
    start_clock()
end)

M.cancel = batch_wrap(function()
    M.type:set(nil)
    M.duration:set(nil)
    end_clock()
end)

return M
