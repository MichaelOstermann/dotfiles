local Buf = require("utils.Buf")
local git = require("custom.git")

local M = {}

function M.run()
    vim.system(
        { "git", "push", "origin", "--tags" },
        {},
        vim.schedule_wrap(function(result)
            local msg = vim.trim(result.stderr or result.stdout)
            local lvl = result.stderr and vim.log.levels.ERROR or vim.log.levels.INFO
            vim.notify(msg, lvl)
            git.refresh()
        end)
    )
end

return M
