local diagnostics = require("utils.diagnostics")
local git = require("utils.git")

-- Wrap lines and enable spellchecking for things like markdown
vim.api.nvim_create_autocmd("FileType", {
    pattern = require("utils.filetypes").prose_filetypes,
    callback = function()
        vim.opt_local.wrap = true
        vim.opt_local.linebreak = true
        vim.opt_local.spell = true
    end,
})

-- Equalize splits after resizing the window
vim.api.nvim_create_autocmd("VimResized", {
    callback = function()
        local current_tab = vim.fn.tabpagenr()
        vim.cmd("tabdo wincmd =")
        vim.cmd("tabnext " .. current_tab)
    end,
})

-- Close terminals with q
vim.api.nvim_create_autocmd("FileType", {
    pattern = "FTerm",
    callback = function(event)
        vim.keymap.set("n", "q", require("FTerm").close, { buffer = event.buf })
    end,
})

-- Disable continuing comments, lists, etc.
vim.api.nvim_create_autocmd("FileType", { callback = function() vim.opt.formatoptions = "" end })

-- Disable diagnostics when entering insert mode
vim.api.nvim_create_autocmd("InsertEnter", { callback = function(evt) diagnostics.disable(evt.buf) end })

-- Enable diagnostics when leaving insert mode
vim.api.nvim_create_autocmd("InsertLeave", { callback = function(evt) diagnostics.enable(evt.buf) end })

-- The filename gets a highlight when there are errors/warnings, keep it refreshed
vim.api.nvim_create_autocmd("DiagnosticChanged", { callback = function() vim.cmd("redrawstatus") end })

-- Refresh statusbars/nvimtree/gitsigns once when entering
vim.api.nvim_create_autocmd("VimEnter", { callback = git.refresh })

-- Refresh statusbars/nvimtree/gitsigns when leaving a terminal, in case I did things
vim.api.nvim_create_autocmd("WinLeave", { pattern = "FTerm", callback = git.refresh })

-- Refresh statusbars/nvimtree/gitsigns after writing to disk
vim.api.nvim_create_autocmd("BufWritePost", { callback = git.refresh })

-- Refresh statusbars/nvimtree/gitsigns when focusing the window, in case I did stuff elsewhere
vim.api.nvim_create_autocmd("FocusGained", { callback = git.refresh })
