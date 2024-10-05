local au = require("utils.autocommand")

vim.opt.autoindent = false
vim.cmd("filetype indent off")
vim.opt.confirm = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.expandtab = true
vim.opt.shiftround = true
vim.opt.hlsearch = false
vim.opt.wrap = false
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.swapfile = false
vim.opt.writebackup = false
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.clipboard = "unnamed"
vim.opt.completeopt = "menuone,noselect"
vim.opt.shortmess = vim.o.shortmess .. "cI"
vim.opt.pumheight = 10
vim.opt.updatetime = 100
vim.opt.undolevels = 5000
vim.opt.laststatus = 3
vim.opt.undofile = true
vim.opt.signcolumn = "yes"
vim.opt.showtabline = 0
vim.opt.title = true
vim.opt.titlestring = "nvim(%{substitute(substitute(getcwd(), $HOME, '~', ''), '\\~/Development/', '', '')})"

vim.opt.fillchars = {
    vert = "▎",
    fold = " ",
    eob = " ",
    diff = "╱",
    msgsep = " ",
    foldopen = "▾",
    foldsep = "│",
    foldclose = "▸",
}

vim.filetype.add({
    pattern = {
        ["tsconfig*.json"] = "jsonc",
        [".*/%.vscode/.*%.json"] = "jsonc",
    },
})

-- Disable continuing comments, lists, etc., something keeps resetting this so it's an autocmd
au("FileType", function()
    vim.opt.formatoptions = ""
end)

-- Settings for markdown, mdx, txt, etc.
au("FileType", function()
    -- Wrap long lines
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true

    -- Enable spellchecking
    vim.opt_local.spell = true

    -- Wrap long lines within lists
    vim.opt_local.breakindent = true
    vim.opt_local.breakindentopt = "list:-1"
end, { pattern = require("utils.filetypes").prose_filetypes })

-- Equalize splits after resizing the window
au("VimResized", function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. current_tab)
end)

-- Check buffers for changes upon leaving term
au("BufLeave", function()
    vim.cmd("checktime")
end, { pattern = "term://*" })
