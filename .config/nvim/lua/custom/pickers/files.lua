local batch = require("signals.batch")
local triple_pane = require("custom.pickers.triple_pane")
local fzy = require("fzy")

local ignores = "!{" .. table.concat(require("utils.filetypes").rg_ignores, ",") .. "}"
local job

local pane = triple_pane({
    title = "Files",
    render = function(line, data)
        line:add(" ")
        local last_offset = 1
        for _, offset in ipairs(data.offsets) do
            line:add(string.sub(data.path, last_offset, offset - 1))
            line:add(string.sub(data.path, offset, offset), "IncSearch")
            last_offset = offset + 1
        end
        line:add(string.sub(data.path, last_offset, -1))
    end,
    refresh = function(pane, manual)
        local prompt = pane.input.content:get()

        if job then
            job:kill()
        end

        job = vim.system(
            {
                "rg",
                "--files",
                "--hidden",
                "--glob",
                ignores,
            },
            {
                text = true,
                env = { NVIM = "", VIM = "" },
                cwd = vim.uv.cwd(),
            },
            vim.schedule_wrap(function(output)
                local files = vim.split(vim.trim(output.stdout), "\n", { plain = true })
                local list = {}

                if prompt and prompt ~= "" then
                    local matches = fzy.filter(prompt, files)
                    matches = vim.tbl_filter(function(match)
                        return match[3] > 0
                    end, matches)
                    table.sort(matches, function(a, b)
                        if a[3] ~= b[3] then
                            return a[3] > b[3]
                        else
                            return files[a[1]] < files[b[1]]
                        end
                    end)
                    for _, match in ipairs(matches) do
                        local row = match[1]
                        local offsets = match[2]
                        table.insert(list, {
                            path = files[row],
                            offsets = offsets,
                        })
                    end
                else
                    for _, path in ipairs(files) do
                        table.insert(list, {
                            path = path,
                            offsets = {},
                        })
                    end
                end

                batch(function()
                    if not manual then
                        pane.results:go_to_top()
                    end
                    pane.results.data:set(list)
                end)
            end)
        )
    end,
})

return {
    open = function()
        pane.tab:open()
    end,
}
