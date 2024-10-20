local utils = require("utils.mappings")
local map = utils.map
local cmd = utils.cmd
local desc = utils.desc
local leader = utils.leader
local buffer = require("utils.buffer")
local treesj = require_lazy("treesj")
local fterm = require_lazy("FTerm")
local grug = require_lazy("grug-far")
local diagnostics = require("custom.diagnostics")
local pomodoro = require("custom.pomodoro")
local t_opts = { jump_type = "never", trim_text = true }

-- Frequently used stuff
map("n", leader("r"), vim.lsp.buf.rename, desc("Rename"))
map("n", leader("R"), grug.open, desc("Search & Replace"))
map("n", leader("h"), vim.lsp.buf.hover, desc("Hover"))
map("n", leader("s"), buffer.format_and_save, desc("Format & Save"))
map("n", leader("j"), treesj.toggle, desc("Split/Join"))
map("n", leader("t"), fterm.open, desc("Terminal"))
map("v", leader("r"), cmd("SearchReplaceSingleBufferVisualSelection"), desc("Replace"))
map("v", leader("R"), grug.with_visual_selection, desc("Search & Replace"))
map("n", leader("y"), function()
    vim.fn.setreg("+", vim.fn.expand("%:p:."))
end, desc("Copy Path"))

-- AI
map("n", leader("ac"), cmd("CodeCompanionChat"), desc("Chat"))
map("n", leader("at"), cmd("CodeCompanionChat Toggle"), desc("Toggle"))

map("n", leader("ag"), function()
    require("codecompanion").prompt("commit")
end, desc("Commit Message"))

map("n", leader("au"), function()
    require("codecompanion").prompt("tests")
end, desc("Unit Tests"))

map("n", leader("af"), function()
    require("codecompanion").prompt("fix")
end, desc("Fix Code"))

map("n", leader("aw"), function()
    require("codecompanion").prompt("workflow")
end, desc("Workflow"))

map("n", leader("ab"), function()
    require("codecompanion").prompt("buffer")
end, desc("Buffer"))

map("n", leader("ae"), function()
    require("codecompanion").prompt("explain")
end, desc("Explain Code"))

map("n", leader("ad"), function()
    require("codecompanion").prompt("lsp")
end, desc("Explain Diagnostics"))

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
map("n", leader("w<left>"), "<c-w>h", desc("Go Left"))
map("n", leader("w<down>"), "<c-w>j", desc("Go Down"))
map("n", leader("w<up>"), "<c-w>k", desc("Go Up"))
map("n", leader("w<right>"), "<c-w>l", desc("Go Right"))

-- Quickfix
map("n", leader("co"), cmd("copen"), desc("Open"))
map("n", leader("cc"), cmd("cclose"), desc("Close"))
map("n", leader("cn"), cmd("cnext"), desc("Next"))
map("n", leader("cp"), cmd("cprevious"), desc("Prev"))

-- Telescope
map("n", leader("ff"), function()
    require("telescope.builtin").find_files()
end, desc("Files"))

map("n", leader("fp"), function()
    require("telescope.builtin").oldfiles({ cwd_only = true })
end, desc("Prev Files"))

map("n", leader("fl"), function()
    require("telescope.builtin").current_buffer_fuzzy_find(t_opts)
end, desc("Lines"))

map("n", leader("fg"), function()
    require("telescope").extensions.egrepify.egrepify()
end, desc("Grep"))

map("n", leader("fi"), function()
    require("telescope.builtin").lsp_implementations(t_opts)
end, desc("Implementations"))

map("n", leader("fd"), function()
    require("telescope.builtin").lsp_definitions(t_opts)
end, desc("Definitions"))

map("n", leader("fr"), function()
    require("telescope.builtin").lsp_references(t_opts)
end, desc("References"))

-- Pomodoro
map("n", leader("pss"), function()
    pomodoro.start_session(15)
end, desc("Short Session"))

map("n", leader("psl"), function()
    pomodoro.start_session(45)
end, desc("Long Session"))

map("n", leader("pbs"), function()
    pomodoro.start_break(5)
end, desc("Short Break"))

map("n", leader("pbl"), function()
    pomodoro.start_break(15)
end, desc("Long Break"))

map("n", leader("pc"), function()
    pomodoro.cancel()
end, desc("Cancel"))
