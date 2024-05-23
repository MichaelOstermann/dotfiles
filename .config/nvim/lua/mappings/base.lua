local utils = require("mappings._utils")
local map = utils.map
local sibling_swap = require_lazy("sibling-swap")
local stay_in_place = require_lazy("stay-in-place")

-- Escape to normal mode in terminals
map("t", "<esc><esc>", "<c-\\><c-n>")

-- Things I keep accidentally pressing in insert mode and mess up my buffers
map("i", "<c-b>", "<nop>")
map("i", "<c-g>", "<nop>")

-- Move around in msgarea
map("c", "<m-left>", "<s-left>")
map("c", "<m-right>", "<s-right>")

-- Move around in insertmode
map("i", "<c-h>", "<left>")
map("i", "<c-j>", "<down>")
map("i", "<c-k>", "<up>")
map("i", "<c-l>", "<right>")

-- Additional breakpoins
map("i", ",", ",<c-g>u")
map("i", ".", ".<c-g>u")
map("i", ";", ";<c-g>u")

-- Yank until end of line
map("n", "Y", "y$")

-- Move lines up/down
map("n", "<c-j>", "<Plug>GoNMLineDown")
map("n", "<c-k>", "<Plug>GoNMLineUp")
map("x", "<c-j>", "<Plug>GoVMLineDown")
map("x", "<c-k>", "<Plug>GoVMLineUp")

-- Move treesitter nodes around
map("n", "<c-h>", sibling_swap.swap_with_left)
map("n", "<c-l>", sibling_swap.swap_with_right)

-- Indent without moving cursors
map("n", "<tab>", stay_in_place.shift_right_line)
map("x", "<tab>", stay_in_place.shift_right_visual)
map("n", "<s-tab>", stay_in_place.shift_left_line)
map("x", "<s-tab>", stay_in_place.shift_left_visual)
