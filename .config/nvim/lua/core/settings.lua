local au = require("utils.autocommand")

vim.opt.autoindent = false
vim.opt.smartindent = false
vim.cmd("filetype indent off")
vim.opt.confirm = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.expandtab = true
vim.opt.shiftround = true
vim.opt.hlsearch = false
vim.opt.wrap = false
vim.opt.number = true
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

vim.opt.fillchars = {
    vert = "│",
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

_G.get_titlestring = function()
    local title = vim.loop
        .cwd()
        :gsub(vim.env.HOME, "~")
        :gsub("~/Development/", "")
        :gsub("~/Library/Mobile Documents/com~apple~CloudDocs/", "iCloud/")
    return "nvim(" .. title .. ")"
end

vim.opt.titlestring = "%{luaeval('get_titlestring()')}"

-- Disable continuing comments, lists, etc., something keeps resetting this so it's an autocmd
au("FileType", function()
    vim.opt.formatoptions = ""
end)

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
