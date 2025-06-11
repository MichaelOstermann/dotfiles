local Win = require("ui").Win

local M = {}

local prompt = nil

local ignores = "!{" .. table.concat(require("utils.filetypes").rg_ignores, ",") .. "}"

function trim_leading(str)
    return (string.gsub(str, "^%s+", ""))
end

function trim_trailing(str)
    return (string.gsub(str, "%s+$", ""))
end

function starts_with(str, prefix)
    return string.sub(str, 1, #prefix) == prefix
end

local win = Win.create({
    actions = {
        open = function(win)
            local data = win:current_line_data()
            win:close()
            vim.cmd("edit " .. vim.fn.fnameescape(data.path))
            if data.pos then
                vim.api.nvim_win_set_cursor(0, data.pos)
            end
        end,
        refresh = function(win)
            vim.ui.input({ prompt = "Search: ", default = prompt }, function(result)
                if result == nil then
                    return
                end

                prompt = result

                vim.system(
                    { "rg", "--json", "--smart-case", "--hidden", "--glob", ignores, prompt },
                    {
                        text = true,
                        env = { NVIM = "", VIM = "" },
                        cwd = vim.uv.cwd(),
                    },
                    vim.schedule_wrap(function(obj)
                        win:clear_lines()
                        local last_path = nil
                        local result = {}

                        for _, line in ipairs(vim.split(obj.stdout, "\n")) do
                            if starts_with(line, '{"type":"match"') then
                                local ok, data =
                                    pcall(vim.json.decode, line, { luanil = { object = true, array = true } })
                                if ok and data.type == "match" then
                                    for _, submatch in ipairs(data.data.submatches) do
                                        table.insert(result, {
                                            path = data.data.path.text,
                                            row = data.data.line_number,
                                            col = submatch.start,
                                            line = data.data.lines.text,
                                            match = submatch.match.text,
                                        })
                                    end
                                end
                            end
                        end

                        table.sort(result, function(a, b)
                            if a.path ~= b.path then
                                return a.path < b.path
                            elseif a.row ~= b.row then
                                return a.row < b.row
                            elseif a.col ~= b.col then
                                return a.col < b.col
                            end
                        end)

                        for _, entry in ipairs(result) do
                            if last_path ~= entry.path then
                                last_path = entry.path
                                win:line():set_data({ path = entry.path }):add(entry.path, "Directory")
                                win:line()
                                    :set_data({ path = entry.path, pos = { entry.row, entry.col } })
                                    :add(entry.row, "LineNr")
                                    :add(":", "LineNr")
                                    :add(entry.col, "LineNr")
                                    :add(" ")
                                    :add(trim_leading(string.sub(entry.line, 1, entry.col)))
                                    :add(entry.match, "IncSearch")
                                    :add(trim_trailing(string.sub(entry.line, entry.col + #entry.match + 1, -1)))
                            end
                        end

                        win:render()
                    end)
                )
            end)
        end,
    },
    mappings = {
        ["<cr>"] = "open",
        r = "refresh",
    },
    on_first_open = function(win)
        win.actions.refresh()
    end,
})

M.run = function()
    win:open()
end

return M
