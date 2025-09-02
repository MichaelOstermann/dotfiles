local Tab = require("ui.Tab")
local Input = require("ui.Input")
local List = require("ui.List")
local Float = require("ui.Float")
local Preview = require("ui.Preview")
local String = require("utils.String")
local Range = require("utils.Range")
local batch = require("signals.batch")
local effect = require("signals.effect")
local fzy = require("fzy")

local preview_width = 90
local ignores = "!{" .. table.concat(require("utils.filetypes").rg_ignores, ",") .. "}"
local job

local function trim_leading(str)
    return (string.gsub(str, "^%s+", ""))
end

local function trim_trailing(str)
    return (string.gsub(str, "%s+$", ""))
end

local prompt = Input.create({
    label = "Ripgrep ",
    focus = true,
    width = function()
        return Float.max_width:get() - preview_width
    end,
})

local include = Input.create({
    top = prompt.bottom,
    label = "Include ",
    width = function()
        return Float.max_width:get() - preview_width
    end,
})

local results = List.create({
    top = include.bottom,
    width = function()
        return Float.max_width:get() - preview_width
    end,
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
})

local preview = Preview.create({
    left = function()
        return results.right:get() + 1
    end,
    width = preview_width - 1,
})

local tab = Tab.create()

local ripgrep = function(manual)
    local prompt = prompt.content:get()
    local include = include.content:get()

    if job then
        job:kill()
    end

    if not prompt or prompt == "" then
        results.data:set({})
        return
    end

    local count = 0
    local files = {}
    local paths = {}
    local cmd = {
        "rg",
        "--json",
        "--fixed-strings",
        "--smart-case",
        "--hidden",
    }

    table.insert(cmd, "--glob")
    table.insert(cmd, ignores)

    if include ~= "" then
        table.insert(cmd, "--glob")
        table.insert(cmd, "{" .. include .. "}")
    end

    table.insert(cmd, prompt)

    job = vim.system(cmd, {
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
                        results:go_to_top()
                    end
                    results.data:set(result)
                end)
                return
            end

            for _, line in ipairs(vim.split(data, "\n", { plain = true })) do
                if vim.startswith(line, '{"type":"match"') then
                    local ok, data =
                        pcall(vim.json.decode, line, { luanil = { object = true, array = true } })
                    if ok and data.type == "match" then
                        if data.data.lines.bytes then
                            goto continue
                        end
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
                        ::continue::
                    end
                end
            end
        end),
    })
end

local open_file = function()
    local selected = results.selected:get() or {}
    vim.cmd.stopinsert()
    vim.schedule(function()
        tab:close_and_edit(selected.path, selected.range)
    end)
end

local close = function()
    tab:close()
end

local refresh_manual = function()
    ripgrep(true)
end

local refresh = function()
    ripgrep(false)
end

tab:on_mount(function()
    prompt:open()
    include:open()
    results:open()
    preview:open()
    vim.cmd("startinsert!")

    prompt:on_focus(function()
        vim.cmd("startinsert!")
    end)

    include:on_focus(function()
        vim.cmd("startinsert!")
    end)

    results:on_focus(function()
        vim.cmd.stopinsert()
    end)

    preview:on_focus(function()
        vim.cmd.stopinsert()
    end)

    prompt:map("n", "r", refresh_manual)
    include:map("n", "r", refresh_manual)
    results:map("n", "r", refresh_manual)
    preview:map("n", "r", refresh_manual)

    prompt:map({ "n", "i" }, "<cr>", open_file)
    include:map({ "n", "i" }, "<cr>", open_file)
    results:map("n", "<cr>", open_file)
    results:map("n", "<2-LeftMouse>", open_file)
    preview:map("n", "<cr>", open_file)

    prompt:map("n", "q", close)
    include:map("n", "q", close)
    results:map("n", "q", close)
    preview:map("n", "q", close)

    prompt:map("n", "gg", function()
        results:go_to_top()
    end)
    prompt:map("n", "G", function()
        results:go_to_bottom()
    end)
    include:map("n", "gg", function()
        results:go_to_top()
    end)
    include:map("n", "G", function()
        results:go_to_bottom()
    end)

    prompt:map({ "n", "i" }, "<down>", function()
        results:go_to_next()
    end)
    prompt:map({ "n", "i" }, "<up>", function()
        results:go_to_prev()
    end)
    include:map({ "n", "i" }, "<down>", function()
        results:go_to_next()
    end)
    include:map({ "n", "i" }, "<up>", function()
        results:go_to_prev()
    end)

    prompt:map({ "n", "i" }, "<tab>", function()
        include:focus()
    end)
    include:map({ "n", "i" }, "<tab>", function()
        results:focus()
    end)
    results:map("n", "<tab>", function()
        preview:focus()
    end)
    preview:map("n", "<tab>", function()
        prompt:focus()
    end)

    prompt:map({ "n", "i" }, "<s-tab>", function()
        preview:focus()
    end)
    include:map({ "n", "i" }, "<s-tab>", function()
        prompt:focus()
    end)
    results:map("n", "<s-tab>", function()
        include:focus()
    end)
    preview:map("n", "<s-tab>", function()
        results:focus()
    end)

    effect(refresh)

    effect(function()
        local current = results.selected:get() or {}
        preview:show_file(current.path, current.range)
    end)
end)

return {
    open = function()
        tab:open()
    end,
}
