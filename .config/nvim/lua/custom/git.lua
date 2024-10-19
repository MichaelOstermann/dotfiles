local effect = require("signals.effect")
local batch = require("signals.batch")
local au = require("utils.autocommand")
local signal = require("signals.signal")
local computed = require("signals.computed")
local signals = require("utils.signals")
local git = require("utils.git")
local async = require("utils.async")
local nvimtree = require("utils.nvimtree")

local M = {}

M.is_repo = signal(false)
M.branch = signal("")
M.status = signal("")
M.refresh_count = signal(0)

M.is_dirty = computed(function()
    local status = M.status:get()
    return string.find(status, "\n") ~= nil
end)

M.ahead = computed(function()
    local status = M.status:get()
    return tonumber(status:match("ahead (%d+)")) or 0
end)

M.behind = computed(function()
    local status = M.status:get()
    return tonumber(status:match("behind (%d+)")) or 0
end)

local refresh = async.batch(function()
    return async.Promise
        .all({
            git.fetch_is_repo(),
            git.fetch_status(),
            git.fetch_branch(),
        })
        :thenCall(vim.schedule_wrap(function(results)
            local is_repo, status, branch = unpack(results)

            batch(function()
                M.is_repo:set(is_repo)
                M.status:set(status)
                M.branch:set(branch)
                M.refresh_count:map(function(count)
                    return count + 1
                end)
            end)
        end))
end)

au("VimEnter", refresh)
au("FocusGained", refresh)
au("BufWritePost", refresh)
au("BufLeave", refresh, { pattern = "term://*" })
au("User", refresh, { pattern = "MiniGitCommandDone" })

effect(function()
    if M.is_repo:is(true) then
        M.status:get()
        nvimtree.reload()
    else
        M.refresh_count:get()
        nvimtree.reload()
    end
end)

return M
