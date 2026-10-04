local Tab = require("picker.Tab")
local Input = require("picker.Input")
local List = require("picker.List")
local Float = require("picker.Float")
local Preview = require("picker.Preview")
local Range = require("picker.Range")
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

local function trim_to(max, parts)
    local left, right = unpack(parts)
    local len_l, len_r = #left, #right

    local excess = len_l + len_r - max

    if excess <= 0 then
        return left, right
    end

    local remove_from_left = 0
    local remove_from_right = 0

    if len_l > len_r then
        local diff = len_l - len_r
        local to_remove = math.min(excess, diff)
        remove_from_left = to_remove
        excess = excess - to_remove
    elseif len_r > len_l then
        local diff = len_r - len_l
        local to_remove = math.min(excess, diff)
        remove_from_right = to_remove
        excess = excess - to_remove
    end

    if excess > 0 then
        local from_each = math.floor(excess / 2)
        remove_from_left = remove_from_left + from_each
        remove_from_right = remove_from_right + from_each + (excess % 2)
    end

    if remove_from_left > 0 then
        remove_from_left = remove_from_left + 1
    end

    if remove_from_right > 0 then
        remove_from_right = remove_from_right + 1
    end

    remove_from_left = math.min(remove_from_left, len_l)
    remove_from_right = math.min(remove_from_right, len_r)

    local final_left = remove_from_left > 0 and "…" .. string.sub(left, remove_from_left + 1)
        or left

    local final_right = remove_from_right > 0
            and string.sub(right, 1, len_r - remove_from_right) .. "…"
        or right

    return final_left, final_right
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
            local left, right = trim_to(max, {
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

    table.insert(cmd, "--")
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
