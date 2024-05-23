return {
    "rebelot/heirline.nvim",
    config = function()
        local git = require("utils.git")
        local filetypes = require("utils.filetypes")
        local conditions = require("heirline.conditions")

        local fill = { provider = "%=" }

        local filename = {
            provider = function()
                local filename = vim.api.nvim_buf_get_name(0)
                return " " .. vim.fn.fnamemodify(filename, ":.")
            end,
            hl = function()
                for _, diag in ipairs(vim.diagnostic.get(0)) do
                    if diag.severity == vim.diagnostic.severity.ERROR then return "ErrorMsg" end
                    if diag.severity == vim.diagnostic.severity.WARN then return "WarningMsg" end
                end
            end,
        }

        local modified = {
            provider = " ●",
            hl = "WarningMsg",
            condition = function()
                return vim.bo.modified
            end,
        }

        local cursor = {
            provider = function()
                local line, col = unpack(vim.api.nvim_win_get_cursor(0))
                return string.format(" %s:%s", line, col + 1)
            end,
        }

        local gitbranch = {
            provider = function()
                return " " .. git.state.branch
            end,
            hl = function()
                if git.state.dirty then
                    return "WarningMsg"
                end
            end,
        }

        local diagnostic_or_signature = {
            provider = function()
                if vim.api.nvim_get_mode().mode == "n" then
                    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
                    local diags = vim.diagnostic.get(0, { lnum = line - 1 })
                    for _, v in pairs(diags) do
                        if v.col <= col and v.end_col >= col then
                            return " " .. v.message
                        end
                    end
                end

                local sig = require("lsp_signature").status_line()
                return " " .. sig.hint
            end,
        }

        local size = {
            provider = function()
                local lines = vim.api.nvim_buf_line_count(0)
                return " " .. lines
            end,
        }

        require("heirline").setup({
            statusline = {
                diagnostic_or_signature,
                fill,
                gitbranch,
                cursor,
            },
            winbar = {
                filename,
                modified,
                size,
            },
            opts = {
                disable_winbar_cb = function(args)
                    return conditions.buffer_matches({
                        buftype = filetypes.special_buftypes,
                    }, args.buf)
                end,
            },
        })
    end,
}
