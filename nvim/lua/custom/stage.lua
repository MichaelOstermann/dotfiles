local Buf = require("utils.Buf")
local git = require("custom.git")

local M = {}

function M.run()
    vim.system(
        { "git", "add", vim.api.nvim_buf_get_name(0) },
        {},
        vim.schedule_wrap(function(result)
            if result.stderr then
                vim.notify(vim.trim(result.stderr), vim.log.levels.ERROR)
            end
            git.refresh()
        end)
    )
end

return M
