local utils = require("utils.mappings")
local map = utils.map
local cmd = utils.cmd
local desc = utils.desc
local leader = utils.leader
local buffer = require("utils.buffer")
local pomodoro = require("custom.pomodoro")

-- Frequently used stuff
map("n", leader("r"), vim.lsp.buf.rename, desc("Rename"))
map("n", leader("R"), lazy_call("grug-far", "open"), desc("Search & Replace"))
map("n", leader("h"), vim.lsp.buf.hover, desc("Hover"))
map("n", leader("s"), buffer.format_and_save, desc("Format & Save"))
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
map("n", leader("au"), lazy_call("codecompanion", "prompt", "tests"), desc("Unit Tests"))
map("n", leader("af"), lazy_call("codecompanion", "prompt", "fix"), desc("Fix Code"))
map("n", leader("aw"), lazy_call("codecompanion", "prompt", "workflow"), desc("Workflow"))
map("n", leader("ab"), lazy_call("codecompanion", "prompt", "buffer"), desc("Buffer"))
map("n", leader("ae"), lazy_call("codecompanion", "prompt", "explain"), desc("Explain Code"))
map("n", leader("ad"), lazy_call("codecompanion", "prompt", "lsp"), desc("Explain Diagnostics"))

-- NvimTree
map("n", leader("e"), cmd("NvimTreeOpen"), desc("Focus Explorer"))
map("n", leader("E"), cmd("NvimTreeFindFile"), desc("Focus File"))

-- Diagnostics
map("n", leader("do"), vim.diagnostic.open_float, desc("Open Diagnostic"))
map("n", leader("dn"), vim.diagnostic.goto_next, desc("Next Diagnostic"))
map("n", leader("dp"), vim.diagnostic.goto_prev, desc("Prev Diagnostic"))
map("n", leader("da"), vim.lsp.buf.code_action, desc("Code Actions"))

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
