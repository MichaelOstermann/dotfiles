local au = require("utils.autocommand")
local utils = require("utils.mappings")
local map = utils.map
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

-- Move lines up/down
map("n", "<c-j>", "<Plug>GoNMLineDown")
map("n", "<c-k>", "<Plug>GoNMLineUp")
map("x", "<c-j>", "<Plug>GoVMLineDown")
map("x", "<c-k>", "<Plug>GoVMLineUp")

-- Flash
map("n", "j", lazy_call("flash", "jump"))
map("o", "j", lazy_call("flash", "remote"))

-- Move treesitter nodes around
map("n", "<c-h>", lazy_call("sibling_swap", "swap_with_left"))
map("n", "<c-l>", lazy_call("sibling_swap", "swap_with_right"))

-- Indent without moving cursors
map("n", "<tab>", lazy_call("stay_in_place", "shift_right_line"))
map("x", "<tab>", lazy_call("stay_in_place", "shift_right_visual"))
map("n", "<s-tab>", lazy_call("stay_in_place", "shift_left_line"))
map("x", "<s-tab>", lazy_call("stay_in_place", "shift_left_visual"))

-- Close terminals with q
au("FileType", function(args)
    vim.keymap.set("n", "q", require("FTerm").close, { buffer = args.buf })
end, { pattern = "FTerm" })
