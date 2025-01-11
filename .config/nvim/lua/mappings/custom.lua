local expr = require("utils.mappings").expr
local b = require("utils.buffer")
local au = require("utils.autocommand")

local function should_skip()
    return b.is_special() or require("multicursor-nvim").hasCursors()
end

local function is_jsdoc()
    if b.is_jsdoc() then
        vim.opt.formatoptions = "ro"
        return true
    else
        vim.opt.formatoptions = ""
        return false
    end
end

local function insert_pair(lhs, rhs)
    return function()
        if not should_skip() then
            return lhs .. rhs .. "<left>"
        end
        return lhs
    end
end

local function skip_pair(lhs, rhs)
    return function()
        if not should_skip() and b.has_surrounding_chars(lhs, rhs) then
            return "<right>"
        end
        return rhs
    end
end

-- Insert pairs
for _, pair in ipairs({
    { "'", "'" },
    { '"', '"' },
    { "`", "`" },
}) do
    local lhs, rhs = unpack(pair)
    expr("i", lhs, insert_pair(lhs, rhs))
end

-- Insert opening pair, skip closing pair
for _, pair in ipairs({
    { "[", "]" },
    { "(", ")" },
    { "{", "}" },
}) do
    local lhs, rhs = unpack(pair)
    expr("i", lhs, insert_pair(lhs, rhs))
    expr("i", rhs, skip_pair(lhs, rhs))
end

-- {|} + space = { | }
expr("i", "<space>", function()
    if not should_skip() and b.has_surrounding_chars("{", "}") then
        return "  <c-g>u<left>"
    end
    return " <c-g>u"
end)

-- `|` + $ = `${|}`
expr("i", "$", function()
    if not should_skip() and b.has_node_type_left("template_string") then
        return "${}<left>"
    end
    return "$"
end)

-- <|> within TS types
expr("i", "<", function()
    if not should_skip() and b.has_node_type_left("type") then
        return "<><left>"
    end
    return "<"
end)

-- Indent after deleting the current line
expr("n", "cc", function()
    local row = unpack(vim.api.nvim_win_get_cursor(0))
    local level = b.get_indentation_level(row)
    return '"_cc' .. b.get_indentation_string(level)
end)

-- Indent after inserting a new line
expr("n", "o", function()
    if is_jsdoc() then
        return "o"
    end
    local row = vim.api.nvim_win_get_cursor(0)[1]
    local level = b.get_indentation_level(row)
    return "o" .. b.get_indentation_string(level)
end)

-- Indent after inserting a new line
expr("n", "O", function()
    if is_jsdoc() then
        return "O"
    end
    local row = vim.api.nvim_win_get_cursor(0)[1]
    local level = b.get_indentation_level(row)
    return "O" .. b.get_indentation_string(level)
end)

-- Delete pairs/spaces on backspace if applicable
expr("i", "<bs>", function()
    if should_skip() then
        return "<bs>"
    end

    if
        b.has_any_surrounding_chars({
            { "'", "'" },
            { '"', '"' },
            { "`", "`" },
            { "[", "]" },
            { "(", ")" },
            { "{", "}" },
            { "{ ", " }" },
            { "<", ">" },
        })
    then
        return "<left><del><del>"
    end

    if b.has_surrounding_chars("{", "  }") then
        return "<del><del>"
    end

    if b.has_surrounding_chars("{  ", "}") then
        return "<left><left><del><del>"
    end

    return "<bs>"
end)

-- Split pairs and indent on cr, if applicable
expr("i", "<cr>", function()
    if is_jsdoc() or should_skip() then
        return "<cr>"
    end

    local level = b.get_current_indentation_level()
    local expand = "<cr><cr>" .. b.get_indentation_string(level) .. "<up>" .. b.get_indentation_string(level + 1)

    if
        b.has_any_surrounding_chars({
            { "{", "}" },
            { "[", "]" },
            { "(", ")" },
            { ">", "<" },
            { "<", ">" },
        })
    then
        return expand
    end

    if b.has_surrounding_chars("{ ", " }") then
        return "<right><bs><bs>" .. expand
    end

    if b.has_surrounding_chars("{", "  }") then
        return "<right><right><bs><bs>" .. expand
    end

    if b.has_surrounding_chars("{  ", "}") then
        return "<bs><bs>" .. expand
    end

    return "<cr>" .. b.get_indentation_string(level)
end)

-- https://github.com/windwp/nvim-ts-autotag/issues/166
-- https://github.com/jake-stewart/multicursor.nvim/issues/39
au("FileType", function()
    local TagConfigs = require("nvim-ts-autotag.config.init")
    local Autotag = require("nvim-ts-autotag.internal")
    local mc = require("multicursor-nvim")

    if TagConfigs:get(vim.bo.filetype) ~= nil then
        vim.keymap.set("i", ">", function()
            if mc.hasCursors() then
                vim.api.nvim_paste(">", false, -1)
            else
                local row, col = unpack(vim.api.nvim_win_get_cursor(0))
                vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col, { ">" })
                Autotag.close_tag()
                vim.api.nvim_win_set_cursor(0, { row, col + 1 })
            end
        end, {
            noremap = true,
            silent = true,
            buffer = true,
        })
    end
end)
