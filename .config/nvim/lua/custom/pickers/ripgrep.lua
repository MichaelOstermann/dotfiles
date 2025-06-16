local String = require("utils.String")
local Range = require("utils.Range")
local batch = require("signals.batch")
local triple_pane = require("custom.pickers.triple_pane")
local fzy = require("fzy")

local ignores = "!{" .. table.concat(require("utils.filetypes").rg_ignores, ",") .. "}"
local job

local function trim_leading(str)
    return (string.gsub(str, "^%s+", ""))
end

local function trim_trailing(str)
    return (string.gsub(str, "%s+$", ""))
end

local function starts_with(str, prefix)
    return string.sub(str, 1, #prefix) == prefix
end

local pane = triple_pane({
    title = "Ripgrep",
    render = function(line, data, row, float)
        if data.type == "directory" then
            line:add(" "):add(data.path, "Directory")
        else
            line:add(" ")
                :add(data.range:get_row_start(), "LineNr")
                :add(":", "LineNr")
                :add(data.range:get_col_end() + 1, "LineNr")
                :add(" ")

            local max = float.width:get() - #data.match - line.length

            -- Trim the context around the match, so everything fits on screen.
            local left, right = String.trim_to(max, {
                trim_leading(string.sub(data.line, 1, data.range:get_col_start())),
                trim_trailing(string.sub(data.line, data.range:get_col_end() + 1, -1)),
            })

            line:add(left)
            line:add(data.match, "IncSearch")
            line:add(right)
        end
    end,
    refresh = function(pane, manual)
        local prompt = pane.input.content:get()

        if job then
            job:kill()
        end

        if not prompt or prompt == "" then
            pane.results.data:set({})
            return
        end

        local count = 0
        local files = {}
        local paths = {}

        job = vim.system({
            "rg",
            "--json",
            "--fixed-strings",
            "--smart-case",
            "--hidden",
            "--glob",
            ignores,
            prompt,
        }, {
            text = true,
            env = { NVIM = "", VIM = "" },
            cwd = vim.uv.cwd(),
            stdout = vim.schedule_wrap(function(job, data)
                if data == nil then
                    local result = {}

                    -- Ripgrep has a sort option, but it forces it into single-threaded mode.
                    table.sort(paths)

                    for _, path in ipairs(paths) do
                        table.insert(result, { type = "directory", path = path })
                        for _, match in ipairs(files[path]) do
                            table.insert(result, match)
                        end
                    end

                    batch(function()
                        if not manual then
                            pane.results:go_to_top()
                        end
                        pane.results.data:set(result)
                    end)
                    return
                end

                for _, line in ipairs(vim.split(data, "\n", { plain = true })) do
                    if starts_with(line, '{"type":"match"') then
                        local ok, data = pcall(
                            vim.json.decode,
                            line,
                            { luanil = { object = true, array = true } }
                        )
                        if ok and data.type == "match" then
                            for _, submatch in ipairs(data.data.submatches) do
                                count = count + 1
                                local path = data.data.path.text
                                if not files[path] then
                                    files[path] = {}
                                    table.insert(paths, path)
                                end
                                table.insert(files[path], {
                                    type = "match",
                                    path = path,
                                    line = data.data.lines.text,
                                    match = submatch.match.text,
                                    range = Range.empty()
                                        :set_rows(data.data.line_number)
                                        :set_anchor_col(submatch.start)
                                        :set_focus_col(submatch["end"]),
                                })
                            end
                        end
                    end
                end
            end),
        })
    end,
})

return {
    open = function()
        pane.tab:open()
    end,
}
