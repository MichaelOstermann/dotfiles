local au = require("utils.autocommand")
local utils = require("utils.mappings")
local map = utils.map
local cmd = utils.cmd
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

-- Horizontal Scrolling
map({ "n", "i", "v" }, "<S-ScrollWheelLeft>", "6zh")
map({ "n", "i", "v" }, "<S-ScrollWheelRight>", "6zl")

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

-- Surround shortcuts
map("x", '"', '<Plug>(nvim-surround-visual)"')
map("x", "'", "<Plug>(nvim-surround-visual)'")
map("x", "`", "<Plug>(nvim-surround-visual)`")
map("x", "(", "<Plug>(nvim-surround-visual)(")
map("x", "{", "<Plug>(nvim-surround-visual){")
map("x", "[", "<Plug>(nvim-surround-visual)[")
map("x", "<", "<Plug>(nvim-surround-visual)<")
map("x", ")", "<Plug>(nvim-surround-visual))")
map("x", "}", "<Plug>(nvim-surround-visual)}")
map("x", "]", "<Plug>(nvim-surround-visual)]")
map("x", ">", "<Plug>(nvim-surround-visual)>")

-- Illuminate
map("n", "<c-n>", lazy_call("illuminate", "goto_next_reference"))
map("n", "<c-p>", lazy_call("illuminate", "goto_prev_reference"))

-- Close terminals with q
au("FileType", function(args)
    vim.keymap.set("n", "q", require("FTerm").close, { buffer = args.buf })
end, { pattern = "FTerm" })

-- Frequently used stuff
map("n", leader("r"), vim.lsp.buf.rename, desc("Rename"))
map("n", leader("R"), lazy_call("grug-far", "open"), desc("Search & Replace"))
map("n", leader("h"), vim.lsp.buf.hover, desc("Hover"))
map("n", leader("s"), lazy_call("utils.buffer", "format_and_save"), desc("Format & Save"))
map("n", leader("j"), lazy_call("treesj", "toggle"), desc("Split/Join"))
map("n", leader("t"), lazy_call("FTerm", "open"), desc("Terminal"))
map("v", leader("r"), cmd("SearchReplaceSingleBufferVisualSelection"), desc("Replace"))
map("v", leader("R"), lazy_call("grug-far", "with_visual_selection"), desc("Search & Replace"))
map("n", leader("y"), function()
    vim.fn.setreg("+", vim.fn.expand("%:p:."))
end, desc("Copy Path"))

-- AI
map("n", leader("ac"), cmd("CodeCompanionChat"), desc("Chat"))
map("n", leader("at"), cmd("CodeCompanionChat Toggle"), desc("Toggle"))
map("n", leader("ag"), lazy_call("codecompanion", "prompt", "commit"), desc("Commit Message"))

-- Flash
map("n", "j", lazy_call("flash", "jump"))
map("o", "j", lazy_call("flash", "remote"))

-- NvimTree
map("n", leader("e"), cmd("NvimTreeOpen"), desc("Focus Explorer"))
map("n", leader("E"), cmd("NvimTreeFindFile"), desc("Focus File"))

-- Diagnostics
map("n", leader("do"), vim.diagnostic.open_float, desc("Open Diagnostic"))
map("n", leader("dn"), vim.diagnostic.goto_next, desc("Next Diagnostic"))
map("n", leader("dp"), vim.diagnostic.goto_prev, desc("Prev Diagnostic"))
map("n", leader("df"), vim.lsp.buf.code_action, desc("Fix Diagnostic"))

-- Git
map("n", leader("gs"), cmd("Git add %"), desc("Stage"))
map("n", leader("gc"), cmd("Git commit"), desc("Commit"))
map("n", leader("gA"), cmd("silent Git commit --amend --no-edit"), desc("Amend"))
map("n", leader("gP"), cmd("Git push -u origin"), desc("Push"))

-- Window
map("n", leader("wc"), "<c-w>c", desc("Close Window"))
map("n", leader("w="), "<c-w>=", desc("Equalize Size"))
map("n", leader("wv"), cmd("vsplit"), desc("Vertical Split"))
map("n", leader("w+"), cmd("vertical resize +1"), desc("Increase Size"))
map("n", leader("w-"), cmd("vertical resize -1"), desc("Decrease Size"))
map("n", leader("wh"), "<c-w>h", desc("Go Left"))
map("n", leader("wj"), "<c-w>j", desc("Go Down"))
map("n", leader("wk"), "<c-w>k", desc("Go Up"))
map("n", leader("wl"), "<c-w>l", desc("Go Right"))

-- Quickfix
map("n", leader("co"), cmd("copen"), desc("Open"))
map("n", leader("cc"), cmd("cclose"), desc("Close"))
map("n", leader("cn"), cmd("cnext"), desc("Next"))
map("n", leader("cp"), cmd("cprevious"), desc("Prev"))

-- Telescope
local t_opts = { jump_type = "never", trim_text = true }
map("n", leader("ff"), lazy_call("telescope.builtin", "find_files"), desc("Files"))
map("n", leader("fp"), lazy_call("telescope.builtin", "oldfiles", { cwd_only = true }), desc("Prev Files"))
map("n", leader("fl"), lazy_call("telescope.builtin", "current_buffer_fuzzy_find", t_opts), desc("Lines"))
map("n", leader("fi"), lazy_call("telescope.builtin", "lsp_implementations", t_opts), desc("Implementations"))
map("n", leader("fd"), lazy_call("telescope.builtin", "lsp_definitions", t_opts), desc("Definitions"))
map("n", leader("fr"), lazy_call("telescope.builtin", "lsp_references", t_opts), desc("References"))
map("n", leader("fg"), cmd("Telescope egrepify"), desc("Grep"))

-- Pomodoro
map("n", leader("pss"), lazy_call("custom.pomodoro", "start_session", 15), desc("Short Session"))
map("n", leader("psl"), lazy_call("custom.pomodoro", "start_session", 45), desc("Long Session"))
map("n", leader("pbs"), lazy_call("custom.pomodoro", "start_break", 5), desc("Short Break"))
map("n", leader("pbl"), lazy_call("custom.pomodoro", "start_break", 15), desc("Long Break"))
map("n", leader("pc"), lazy_call("custom.pomodoro", "cancel"), desc("Cancel"))

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
    end
end)
