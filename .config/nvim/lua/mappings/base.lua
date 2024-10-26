local au = require("utils.autocommand")
local utils = require("utils.mappings")
local map = utils.map
local desc = utils.desc
local leader = utils.leader
local expr = utils.expr

-- Escape to normal mode in terminals
map("t", "<esc><esc>", "<c-\\><c-n>")

-- Things I keep accidentally pressing in insert mode and mess up my buffers
map("i", "<c-b>", "<nop>")
map("i", "<c-g>", "<nop>")

-- Move up/down while considering word wrap
expr("n", "j", [[(v:count > 1 ? 'm`' . v:count : 'g') . 'j']])
expr("n", "k", [[(v:count > 1 ? 'm`' . v:count : 'g') . 'k']])

-- Move around in msgarea
map("c", "<m-left>", "<s-left>")
map("c", "<m-right>", "<s-right>")

-- Move around in insertmode
map("i", "<c-h>", "<left>")
map("i", "<c-j>", "<c-o>gj")
map("i", "<c-k>", "<c-o>gk")
map("i", "<c-l>", "<right>")

-- Additional breakpoins
map("i", ",", ",<c-g>u")
map("i", ".", ".<c-g>u")
map("i", ";", ";<c-g>u")

-- Prevent yanking on paste
map("v", "p", "P")

-- Delete char
map("n", "<bs>", '"_dl')
map("v", "<bs>", '"_d')

-- Move lines up/down
map("n", "<c-down>", "<Plug>GoNMLineDown")
map("n", "<c-up>", "<Plug>GoNMLineUp")
map("x", "<c-down>", "<Plug>GoVMLineDown")
map("x", "<c-up>", "<Plug>GoVMLineUp")

-- Move treesitter nodes around
map("n", "<c-left>", lazy_call("sibling-swap", "swap_with_left"))
map("n", "<c-right>", lazy_call("sibling-swap", "swap_with_right"))

-- Indent without moving cursors
map("n", "<tab>", lazy_call("stay-in-place", "shift_right_line"))
map("x", "<tab>", lazy_call("stay-in-place", "shift_right_visual"))
map("n", "<s-tab>", lazy_call("stay-in-place", "shift_left_line"))
map("x", "<s-tab>", lazy_call("stay-in-place", "shift_left_visual"))

-- Illuminate
map("n", "<c-n>", lazy_call("illuminate", "goto_next_reference"))
map("n", "<c-p>", lazy_call("illuminate", "goto_prev_reference"))

-- Close terminals with q
au("FileType", function(args)
    vim.keymap.set("n", "q", require("FTerm").close, { buffer = args.buf })
end, { pattern = "FTerm" })

-- Flash
map("n", "j", lazy_call("flash", "jump"))
map("o", "j", lazy_call("flash", "remote"))

-- Multicursor
map("v", "I", lazy_call("multicursor-nvim", "insertVisual"))
map("v", "A", lazy_call("multicursor-nvim", "appendVisual"))
map("n", "<c-leftmouse>", lazy_call("multicursor-nvim", "handleMouse"))
map({ "n", "v" }, "<a-up>", lazy_call("multicursor-nvim", "lineAddCursor", -1))
map({ "n", "v" }, "<a-down>", lazy_call("multicursor-nvim", "lineAddCursor", 1))
map({ "n", "v" }, "<c-m>", lazy_call("multicursor-nvim", "addCursor", "*"))
map("n", "<leader>mA", lazy_call("multicursor-nvim", "matchAllAddCursors"), desc("Match all"))
map("n", "<leader>ma", lazy_call("multicursor-nvim", "alignCursors"), desc("Align"))
map({ "n", "v" }, "<leader>mt", lazy_call("multicursor-nvim", "toggleCursor"), desc("Toggle"))
map("n", "<leader>mr", lazy_call("multicursor-nvim", "restoreCursors"), desc("Restore"))
map("v", "<leader>ms", lazy_call("multicursor-nvim", "splitCursors"), desc("Split"))
map("v", "<leader>mm", lazy_call("multicursor-nvim", "matchCursors"), desc("Match"))

vim.keymap.set("n", "<esc>", function()
    local mc = require("multicursor-nvim")

    if not mc.cursorsEnabled() then
        mc.enableCursors()
    elseif mc.hasCursors() then
        mc.clearCursors()
    else
        -- Default <esc> handler.
    end
end)
