local Tab = require("ui.Tab")
local Input = require("ui.Input")
local List = require("ui.List")
local Float = require("ui.Float")
local Preview = require("ui.Preview")
local effect = require("signals.effect")
local batch = require("signals.batch")
local fzy = require("fzy")

local preview_width = 90
local ignores = "!{" .. table.concat(require("utils.filetypes").rg_ignores, ",") .. "}"
local job

local prompt = Input.create({
    label = "Files ",
    focus = true,
    width = function()
        return Float.max_width:get() - preview_width
    end,
})

local results = List.create({
    top = prompt.bottom,
    width = function()
        return Float.max_width:get() - preview_width
    end,
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
                    results:go_to_top()
                end
                results.data:set(list)
            end)
        end)
    )
end

local open_file = function()
    local selected = results.selected:get() or {}
    tab:close_and_edit(selected.path, selected.range)
end

local close = function()
    tab:close()
end

local refresh_manual = function()
    ripgrep(pane, true)
end

local refresh = function()
    ripgrep(pane, false)
end

tab:on_mount(function()
    prompt:open()
    results:open()
    preview:open()

    prompt:map("n", "r", refresh_manual)
    results:map("n", "r", refresh_manual)
    preview:map("n", "r", refresh_manual)

    prompt:map("n", "<cr>", open_file)
    results:map("n", "<cr>", open_file)
    results:map("n", "<2-LeftMouse>", open_file)
    preview:map("n", "<cr>", open_file)

    prompt:map("n", "q", close)
    results:map("n", "q", close)
    preview:map("n", "q", close)

    prompt:map("n", "gg", function()
        results:go_to_top()
    end)
    prompt:map("n", "G", function()
        results:go_to_bottom()
    end)
    prompt:map("n", "<down>", function()
        results:go_to_next()
    end)
    prompt:map("n", "<up>", function()
        results:go_to_prev()
    end)

    prompt:map("n", "<tab>", function()
        results:focus()
    end)
    results:map("n", "<tab>", function()
        preview:focus()
    end)
    preview:map("n", "<tab>", function()
        prompt:focus()
    end)

    prompt:map("n", "<s-tab>", function()
        preview:focus()
    end)
    results:map("n", "<s-tab>", function()
        prompt:focus()
    end)
    preview:map("n", "<s-tab>", function()
        results:focus()
    end)

    prompt:map("n", "<esc>", function()
        prompt:clear_lines()
    end)
    results:map("n", "<esc>", function()
        prompt:focus()
    end)
    preview:map("n", "<esc>", function()
        prompt:focus()
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
