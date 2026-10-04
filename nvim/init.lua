function lazy_call(require_path, method, ...)
    local args = { ... }
    return function()
        return require(require_path)[method](unpack(args))
    end
end

require("theme")

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("lazy").setup({
    ui = {
        size = {
            width = 1,
            height = 1,
        },
    },
    spec = {
        { import = "plugins" },
    },
    change_detection = {
        enabled = false,
    },
    performance = {
        rtp = {
            disabled_plugins = {
                "gzip",
                "man",
                "matchit",
                "matchparen",
                "netrwPlugin",
                "rplugin",
                "tarPlugin",
                "tohtml",
                "tutor",
                "zipPlugin",
            },
        },
    },
})

require("settings")
require("autounload")

require("statusline.diagnostics")
require("statusline.signature")
require("statusline")
require("statusline.winbar")

require("mappings")
require("autopairs")
