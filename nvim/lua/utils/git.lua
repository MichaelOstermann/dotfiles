local async = require("utils.async")
local signals = require("utils.signals")

local M = {}

M.fetch_is_repo = function()
    return async
        .system("git", { "rev-parse", "--is-inside-work-tree" })
        :thenCall(function()
            return true
        end)
        :catch(function()
            return false
        end)
end

M.fetch_status = function()
    return async.system("git", { "status", "--porcelain", "-u", "--branch" }):catch(function()
        return ""
    end)
end

M.fetch_branch = function()
    return async.system("git", { "branch", "--show-current" }):catch(function()
        return ""
    end)
end

return M
