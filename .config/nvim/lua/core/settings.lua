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
    extension = { mdx = "mdx" },
    pattern = {
        ["tsconfig*.json"] = "jsonc",
        [".*/%.vscode/.*%.json"] = "jsonc",
    },
})
