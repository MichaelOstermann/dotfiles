local au = require("utils.autocommand")

local lru_bufs = {}

-- Remove the current buffer from our list and append it, maintaining a LRU list.
-- While at it, remove any buffers that have been unloaded in the meantime,
-- to prevent the list from growing indefinitely.
local function add_current_buf()
    local cur_buf = vim.api.nvim_get_current_buf()
    lru_bufs = vim.tbl_filter(function(buf)
        return buf ~= cur_buf and vim.api.nvim_buf_is_loaded(buf)
    end, lru_bufs)
    table.insert(lru_bufs, cur_buf)
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
        -- Must be a buffer associated with a file on disk.
        return vim.api.nvim_buf_get_name(buf) ~= ""
            -- Ignore buffers that are unlisted.
            and vim.api.nvim_buf_get_option(buf, "buflisted")
            -- Ignore modified/unsaved buffers.
            and not vim.api.nvim_buf_get_option(buf, "modified")
            -- Ignore buffers currently present in any window.
            and not vim.list_contains(visible_bufs, buf)
    end, lru_bufs)
end

au("BufEnter", function()
    add_current_buf()
    local unloadable_bufs = get_unloadable_bufs()
    if #unloadable_bufs > 10 then
        vim.api.nvim_buf_delete(unloadable_bufs[1], {})
    end
end)
