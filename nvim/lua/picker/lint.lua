local Range = require("picker.Range")
local batch = require("signals.batch")
local signal = require("signals.signal")
local dual_pane = require("picker.dual_pane")

local job
local title = signal("Lint")

local severities = {
    "DiagnosticSignWarn",
    "DiagnosticSignError",
}

local function find_bin(name)
    local path = vim.fn.findfile("node_modules/.bin/" .. name, ".;")
    if path ~= "" and vim.fn.executable(path) == 1 then
        return path
    end
end

-- Each linter runs with the binary the project installed, and turns its JSON into results grouped by file:
-- `{ path, severity (1 warning, 2 error), message, rule, range? }`.
local linters = {
    {
        name = "Oxlint",
        -- Projects on @monstermann/stdlib-style, which ESLint projects never have.
        detect = function()
            local config = vim.fs.find({ "oxlint.config.ts", ".oxlintrc.json" }, { upward = true, type = "file" })[1]
            return config and find_bin("oxlint")
        end,
        args = { "--format", "json" },
        parse = function(data)
            local results = {}
            for _, diagnostic in ipairs(data.diagnostics or {}) do
                local result = {
                    path = diagnostic.filename,
                    severity = diagnostic.severity == "error" and 2 or 1,
                    message = diagnostic.message,
                    -- Without a code it is a disable comment that disables nothing.
                    rule = diagnostic.code or "unused-directive",
                }
                -- Oxlint tells where a finding starts and how long it is, not where it ends.
                local span = diagnostic.labels and diagnostic.labels[1] and diagnostic.labels[1].span
                if span then
                    result.range = Range.empty()
                        :set_anchor_row(span.line)
                        :set_focus_row(span.line)
                        :set_anchor_col(span.column - 1)
                        :set_focus_col(span.column - 1 + span.length)
                end
                table.insert(results, result)
            end
            -- In the order of the files, the way ESLint reports them.
            table.sort(results, function(a, b)
                if a.path ~= b.path then
                    return a.path < b.path
                end
                return a.range and b.range and a.range:get_row_start() < b.range:get_row_start() or false
            end)
            return results
        end,
    },
    {
        name = "ESLint",
        detect = function()
            return find_bin("eslint")
        end,
        args = { ".", "--format", "json" },
        parse = function(data)
            local results = {}
            for _, file in ipairs(data or {}) do
                for _, msg in ipairs(file.messages) do
                    local result = {
                        path = vim.fs.relpath(vim.fn.getcwd(), file.filePath),
                        severity = msg.severity,
                        message = msg.message,
                        rule = msg.ruleId,
                    }
                    if msg.line and msg.column then
                        result.range = Range.empty()
                            :set_anchor_row(msg.line)
                            :set_focus_row(msg.endLine or msg.line)
                            :set_anchor_col(msg.column - 1)
                            :set_focus_col((msg.endColumn or msg.column) - 1)
                    end
                    table.insert(results, result)
                end
            end
            return results
        end,
    },
}

local pane = dual_pane({
    title = title,
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

            line:add(data.message):add(" "):add(data.rule, "Keyword")
        end
    end,
    refresh = function(pane)
        if job then
            job:kill()
        end

        local linter, bin
        for _, candidate in ipairs(linters) do
            bin = candidate.detect()
            if bin then
                linter = candidate
                break
            end
        end
        if not linter then
            return
        end

        title:set(linter.name)
        pane.title.spinner:start()

        job = vim.system(
            vim.list_extend({ bin }, linter.args),
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
                    for _, entry in ipairs(linter.parse(data)) do
                        if last_path ~= entry.path then
                            last_path = entry.path
                            table.insert(list, { type = "directory", path = entry.path })
                        end
                        entry.type = "result"
                        entry.message = entry.message:gsub("\n+", "")
                        table.insert(list, entry)
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
