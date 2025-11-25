local Buf = require("utils.Buf")
local git = require("custom.git")
local map = require("utils.mappings").map

local M = {}

function M.run()
    vim.system(
        { "git", "commit", "--dry-run" },
        {},
        vim.schedule_wrap(function(result)
            local content = vim.trim(result.stdout)
            content = vim.split(content, "\n", { plain = true })
            content = vim.list_extend({
                "Please enter the commit message for your changes. Lines starting",
                "with '#' will be ignored, and an empty message aborts the commit.",
                "",
            }, content)
            content = vim.tbl_map(function(line)
                if vim.startswith(line, "\t") then
                    return "#" .. line
                else
                    return "# " .. line
                end
            end, content)
            table.insert(content, 1, "")

            vim.cmd("tabnew")

            local buf = Buf.current()
                :set_buftype("nofile")
                :set_bufhidden("wipe")
                :set_buflisted(false)
                :set_filetype("gitcommit")
                :set_lines(1, -1, content)

            map("n", "<leader>s", function()
                vim.system(
                    {
                        "git",
                        "commit",
                        "--cleanup",
                        "strip",
                        "--message",
                        table.concat(buf:get_lines(), "\n"),
                    },
                    {},
                    vim.schedule_wrap(function(result)
                        local msg = vim.trim(result.stderr or result.stdout)
                        local lvl = result.stderr and vim.log.levels.ERROR or vim.log.levels.INFO
                        vim.notify(msg, lvl)
                        vim.cmd("tabclose")
                        git.refresh()
                    end)
                )
            end, { buffer = true })
        end)
    )
end

return M
