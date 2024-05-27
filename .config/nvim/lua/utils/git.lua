local async = require("utils.async")
local buffer = require("utils.buffer")
local nvimtree = require("utils.nvimtree")
local gitsigns = require_lazy("gitsigns")

local Promise = async.Promise
local batch = async.batch
local system = async.system
local prompt = async.prompt
local success = async.success
local error = async.error

local M = {
    state = {
        dirty = false,
        branch = "",
        status = "",
    },
}

local fetch_status = batch(function()
    return system("git", { "status", "--porcelain", "-u" })
end)

local fetch_dirty = batch(function()
    return fetch_status():thenCall(function(status)
        return status ~= ""
    end)
end)

local fetch_branch = batch(function()
    return system("git", { "branch", "--show-current" })
end)

local get_last_commit_message = batch(function()
    return system("git", { "log", "-1", "--pretty=%B" })
        :thenCall(vim.trim)
end)

M.refresh = batch(function()
    return Promise
        .all({
            fetch_status(),
            fetch_dirty(),
            fetch_branch(),
        })
        :thenCall(vim.schedule_wrap(function(results)
            local status, dirty, branch = unpack(results)

            local state = {
                status = status,
                dirty = dirty,
                branch = branch,
            }

            if vim.deep_equal(M.state, state) then return end

            M.state = state
            gitsigns.refresh()
            nvimtree.reload()
            vim.cmd("redrawstatus")
        end))
end)

M.stage = function(path)
    path = path or vim.api.nvim_buf_get_name(0)
    local relPath = vim.fn.fnamemodify(path, ":p:~:.")

    return system("git", { "add", path })
        :thenCall(success("Staged: " .. relPath))
        :catch(error)
        :thenCall(M.refresh)
end

M.commit = function()
    prompt("Commit: ", "")
        :thenCall(function(message)
            if message == "" then return end

            return system("git", { "commit", "-m", message })
                :thenCall(success("Committed: " .. message))
                :thenCall(M.refresh)
        end)
        :catch(error)
end

M.amend = function()
    return get_last_commit_message()
        :thenCall(function(message)
            return prompt("Amend: ", message)
        end)
        :thenCall(function(message)
            if message == "" then return end
            return system("git", { "commit", "--amend", "-m", message })
                :thenCall(success("Amended: " .. message))
                :thenCall(M.refresh)
        end)
        :catch(error)
end

return M
