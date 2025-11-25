local M = {}
local S = {}

local spinners = {
    "·",
    "✶",
    "✳",
    "✢",
    "✻",
    "✽",
}

local messages = {
    "Analyzing…",
    "Architecting…",
    "Assembling…",
    "Blossoming…",
    "Brewing…",
    "Building…",
    "Calculating…",
    "Checking…",
    "Coalescing…",
    "Combining…",
    "Compiling…",
    "Composing…",
    "Computing…",
    "Conjuring…",
    "Connecting…",
    "Considering…",
    "Consulting…",
    "Cooking…",
    "Correlating…",
    "Cracking…",
    "Creating…",
    "Cross-referencing…",
    "Decoding…",
    "Deconstructing…",
    "Decrypting…",
    "Double-checking…",
    "Drafting…",
    "Engaging…",
    "Enhancing…",
    "Evaluating…",
    "Evolving…",
    "Executing…",
    "Exploring…",
    "Extracting…",
    "Filtering…",
    "Fine-tuning…",
    "Formulating…",
    "Generating…",
    "Hacking…",
    "Indexing…",
    "Initializing…",
    "Interpreting…",
    "Iterating…",
    "Manifesting…",
    "Navigating…",
    "Optimizing…",
    "Painting…",
    "Parsing…",
    "Plotting…",
    "Polishing…",
    "Pondering…",
    "Processing…",
    "Querying…",
    "Rebalancing…",
    "Rebooting…",
    "Recalibrating…",
    "Recharging…",
    "Reconstructing…",
    "Refining…",
    "Reigniting…",
    "Reinvigorating…",
    "Retrieving…",
    "Reviewing…",
    "Rewinding…",
    "Rewiring…",
    "Rummaging…",
    "Running…",
    "Scanning…",
    "Searching…",
    "Sharpening…",
    "Shimmering…",
    "Shuffling…",
    "Sketching…",
    "Soaring…",
    "Spinning…",
    "Stirring…",
    "Structuring…",
    "Summoning…",
    "Syncing…",
    "Synthesizing…",
    "Thinking…",
    "Translating…",
    "Transmuting…",
    "Tuning…",
    "Unfolding…",
    "Unpacking…",
    "Untangling…",
    "Validating…",
    "Verifying…",
    "Weaving…",
}

S.start = function(spinner)
    if spinner.is_running then
        return
    end

    spinner.is_running = true
    spinner.offset_spinner = 1
    spinner.messages = vim.deepcopy(messages)

    if spinner.on_start then
        spinner.on_start()
    end

    spinner:tick()

    spinner.timer_spinner:start(0, 100, function()
        spinner.offset_spinner = spinner.offset_spinner + 1
        if spinner.offset_spinner > #spinners then
            spinner.offset_spinner = 1
        end

        spinner:tick()
    end)

    spinner.timer_message:start(0, 1000, function()
        if #spinner.messages == 0 then
            spinner.messages = vim.deepcopy(messages)
        end
        local pos = math.random(#spinner.messages)
        spinner.message = table.remove(spinner.messages, pos)
        spinner:tick()
    end)
end

S.stop = function(spinner)
    if not spinner.is_running then
        return
    end

    spinner.timer_spinner:stop()
    spinner.timer_message:stop()
    spinner.is_running = false

    if spinner.on_stop then
        spinner.on_stop()
    end
end

S.tick = vim.schedule_wrap(function(spinner)
    if spinner.on_tick then
        spinner.on_tick(spinners[spinner.offset_spinner] .. " " .. spinner.message)
    end
end)

M.create = function(options)
    return setmetatable({
        is_running = false,
        offset_spinner = 1,
        messages = nil,
        message = nil,
        timer_spinner = vim.uv.new_timer(),
        timer_message = vim.uv.new_timer(),
        on_start = options.on_start,
        on_stop = options.on_stop,
        on_tick = options.on_tick,
    }, {
        __index = S,
    })
end

return M
