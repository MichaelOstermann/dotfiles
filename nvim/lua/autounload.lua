local au = require("utils.autocommand")

local lru_bufs = {}

local is_file = function(buf)
    return vim.api.nvim_buf_is_loaded(buf)
        and vim.api.nvim_buf_get_name(buf) ~= ""
        and vim.api.nvim_get_option_value("buftype", { buf = buf }) == ""
end

local function add_buf(buf)
    if not is_file(buf) then
        return
    end

    lru_bufs = vim.tbl_filter(function(lru_buf)
        return lru_buf ~= buf and vim.api.nvim_buf_is_loaded(lru_buf)
    end, lru_bufs)

    table.insert(lru_bufs, buf)
end

local function get_visible_bufs()
    local bufs = {}
    for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
            local buf = vim.api.nvim_win_get_buf(win)
            if not vim.list_contains(bufs, buf) then
                table.insert(bufs, buf)
            end
        end
    end
    return bufs
end

local function get_unloadable_bufs()
    local visible_bufs = get_visible_bufs()
    return vim.tbl_filter(function(buf)
        return vim.api.nvim_buf_is_loaded(buf)
            and vim.api.nvim_buf_get_option(buf, "modified") == false
            and vim.list_contains(visible_bufs, buf) == false
    end, lru_bufs)
end

au({ "BufEnter", "BufWinEnter" }, function(evt)
    add_buf(evt.buf)
    local unloadable_bufs = get_unloadable_bufs()
    if #unloadable_bufs > 10 then
        local buf = table.remove(unloadable_bufs, 1)
        vim.api.nvim_buf_delete(buf, {})
    end
end)
