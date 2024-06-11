local effect = require("signals.effect")
local computed = require("signals.computed")
local signals = require("utils.signals")
local statusline = require("utils.statusline")
local git = require("custom.git")
local pomodoro = require("custom.pomodoro")

local git_branch = statusline.component(function()
    local branch = git.branch:get()
    if branch == "" then
        return
    end
    return { " ", { branch, { WarningMsg = git.is_dirty:get() } } }
end)

local git_ahead = statusline.component(function()
    local ahead = git.ahead:get()
    if ahead == 0 then
        return
    end
    return { " ", { "+" .. git.ahead:get(), "String" } }
end)

local git_behind = statusline.component(function()
    local behind = git.behind:get()
    if behind == 0 then
        return
    end
    return { " ", { "-" .. git.behind:get(), "ErrorMsg" } }
end)

local pos = statusline.component(function()
    return { " ", signals.row:get(), ":", signals.col:get() + 1 }
end)

local lines = statusline.component(function()
    return { " ", signals.lines:get(), "L" }
end)

local pom = statusline.component(function()
    if pomodoro.is_running:is(false) then
        return
    end
    local session_icon = pomodoro.type:is("session") and "" or ""
    local break_icon = pomodoro.type:is("break") and "" or ""
    return { " ", session_icon, break_icon, "  ", pomodoro.time_left:get() }
end)

local right = statusline.components({
    git_branch,
    git_ahead,
    git_behind,
    pos,
    lines,
    pom,
})

local available_width = computed(function()
    return signals.width:get() - right.size:get()
end)

local function truncate(content)
    local width = vim.fn.strdisplaywidth(content)
    local diff = available_width:get() - width
    if diff > 0 then
        return content
    end
    return string.sub(content, 1, diff - 2) .. "…"
end

local diagnostic = statusline.component(function()
    if not signals.diagnostics_enabled:get() then
        return
    end
    if signals.mode:get() ~= "n" then
        return
    end
    local diagnostic = signals.diagnostic:get()
    return diagnostic
        and {
            {
                truncate(diagnostic.message),
                {
                    ErrorMsg = diagnostic.severity == vim.diagnostic.severity.ERROR,
                    WarningMsg = diagnostic.severity == vim.diagnostic.severity.WARN,
                },
            },
        }
end)

local function is_valid_range(range)
    if not range then
        return false
    end
    return range["end"] > range.start
end

local signature = statusline.component(function()
    if diagnostic.size:get() > 0 then
        return
    end

    local signature = signals.signature:get()

    if not signature then
        return
    end

    if signals.mode:get() == "i" then
        return { truncate(signature.hint) }
    end

    if vim.fn.strdisplaywidth(signature.label) > available_width:get() then
        return { truncate(signature.hint) }
    end

    local range = signature.range

    if not is_valid_range(range) then
        return { signature.label }
    end

    return {
        { string.sub(signature.label, 1, range.start - 1) },
        { string.sub(signature.label, range.start, range["end"]), "MoreMsg" },
        { string.sub(signature.label, range["end"] + 1) },
    }
end)

local left = statusline.components({
    diagnostic,
    signature,
})

local padding = computed(function()
    local available_width = signals.width:get() - left.size:get() - right.size:get()
    return string.rep(" ", available_width)
end)

effect(function()
    vim.o.statusline = left.content:get() .. padding:get() .. right.content:get()
end)
