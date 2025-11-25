local Lsp = require("utils.lsp")
local Range = require("utils.Range")
local batch = require("signals.batch")
local dual_pane = require("custom.pickers.dual_pane")

local job

local severities = {
    "DiagnosticSignWarn",
    "DiagnosticSignError",
}

local function is_executable(cmd)
    return cmd and vim.fn.executable(cmd) == 1 or false
end

local function find_eslint_bin()
    local path = vim.fn.findfile("node_modules/.bin/eslint", ".;")
    if path ~= "" then
        return path
    end
    return "eslint"
end

local pane = dual_pane({
    title = "Eslint",
    render = function(line, data)
        if data.type == "directory" then
            line:add(" "):add(data.path, "Directory")
        else
            line:add(" "):add("▎", severities[data.severity])

            if data.range then
                line:add(data.range:get_row_start(), "LineNr")
                    :add(":", "LineNr")
                    :add(data.range:get_col_start() + 1, "LineNr")
                    :add(" ")
            end

            line:add(data.message):add(" "):add(data.ruleId, "Keyword")
        end
    end,
    refresh = function(pane)
        if job then
            job:kill()
        end

        local bin = find_eslint_bin()
        if not is_executable(bin) then
            return
        end

        pane.title.spinner:start()

        job = vim.system(
            { bin, ".", "--format", "json" },
            {
                text = true,
                env = { NVIM = "", VIM = "" },
                cwd = vim.uv.cwd(),
            },
            vim.schedule_wrap(function(result)
                pane.title.spinner:stop()

                local ok, data = pcall(
                    vim.json.decode,
                    result.stdout,
                    { luanil = { object = true, array = true } }
                )

                local list = {}
                local last_path

                if ok then
                    for _, entry in ipairs(data or {}) do
                        if #entry.messages > 0 then
                            local path = vim.fs.relpath(vim.fn.getcwd(), entry.filePath)

                            if last_path ~= path then
                                last_path = path
                                table.insert(list, { type = "directory", path = path })
                            end

                            for _, msg in ipairs(entry.messages) do
                                local entry = {
                                    type = "result",
                                    path = path,
                                    severity = msg.severity,
                                    message = msg.message,
                                    ruleId = msg.ruleId,
                                }

                                if msg.line and msg.column then
                                    entry.range = Range.empty()
                                        :set_anchor_row(msg.line)
                                        :set_focus_row(msg.endLine or msg.line)
                                        :set_anchor_col(msg.column - 1)
                                        :set_focus_col((msg.endColumn or msg.column) - 1)
                                end

                                table.insert(list, entry)
                            end
                        end
                    end
                end

                batch(function()
                    pane.results:go_to_top()
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
