local utils = require("utils.mappings")
local map = utils.map
local cmd = utils.cmd
local desc = utils.desc
local leader = utils.leader
local buffer = require("utils.buffer")
local diagnostics = require("utils.diagnostics")
local treesj = require_lazy("treesj")
local fterm = require_lazy("FTerm")
local t_opts = { jump_type = "never", trim_text = true }

-- Frequently used stuff
map("n", leader("r"), vim.lsp.buf.rename, desc("Rename"))
map("n", leader("h"), vim.lsp.buf.hover, desc("Hover"))
map("n", leader("a"), vim.lsp.buf.code_action, desc("Actions"))
map("n", leader("s"), buffer.format_and_save, desc("Format & Save"))
map("n", leader("j"), treesj.toggle, desc("Split/Join"))
map("n", leader("t"), fterm.open, desc("Terminal"))
map("v", leader("r"), cmd("SearchReplaceSingleBufferVisualSelection"), desc("Replace"))
map("n", leader("y"), function()
    vim.fn.setreg("+", vim.fn.expand("%:p:."))
end, desc("Copy Path"))

-- NvimTree
map("n", leader("ee"), cmd("NvimTreeOpen"), desc("Open"))
map("n", leader("ef"), cmd("NvimTreeFindFile"), desc("Focus File"))
map("n", leader("ec"), cmd("NvimTreeClose"), desc("Close"))
map("n", leader("e+"), cmd("NvimTreeResize +1"), desc("Increase Size"))
map("n", leader("e-"), cmd("NvimTreeResize -1"), desc("Decrease Size"))
map("n", leader("e="), cmd("NvimTreeResize 35"), desc("Default Size"))

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

-- Git
map("n", leader("gs"), cmd("Git add %"), desc("Stage"))
map("n", leader("gc"), cmd("Git commit"), desc("Commit"))
map("n", leader("gp"), cmd("Git push -u origin"), desc("Push"))

-- Diagnostics
map("n", leader("dr"), diagnostics.reset, desc("Restart"))
map("n", leader("do"), vim.diagnostic.open_float, desc("Open"))
map("n", leader("dn"), vim.diagnostic.goto_next, desc("Next"))
map("n", leader("dp"), vim.diagnostic.goto_prev, desc("Prev"))
