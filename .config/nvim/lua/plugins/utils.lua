return {
    -- Similar to which-key, but I prefer mini's take on it + it supports hydra-like submodes
    {
        "echasnovski/mini.clue",
        version = "*",
        event = "VeryLazy",
        config = function()
            local miniclue = require("mini.clue")
            miniclue.setup({
                window = { delay = 300 },
                triggers = {
                    { mode = 'n', keys = '<Leader>' },
                    { mode = 'v', keys = '<Leader>' },
                },
                clues = {
                    miniclue.gen_clues.builtin_completion(),
                    { mode = "n", keys = "<Leader>d", desc = "+diagnostics" },
                    { mode = "n", keys = "<Leader>w", desc = "+windows" },
                    { mode = "n", keys = "<Leader>f", desc = "+find" },
                    { mode = "n", keys = "<Leader>g", desc = "+git" },
                    { mode = "n", keys = "<Leader>w+", postkeys = "<Leader>w" },
                    { mode = "n", keys = "<Leader>w-", postkeys = "<Leader>w" },
                    { mode = "n", keys = "<Leader>e", desc = "+explorer" },
                    { mode = "n", keys = "<Leader>e+", postkeys = "<Leader>e" },
                    { mode = "n", keys = "<Leader>e-", postkeys = "<Leader>e" },
                },
            })
        end
    },

    -- Easymotion-like goodies
    {
        "folke/flash.nvim",
        event = "VeryLazy",
        opts = {
            modes = {
                char = {
                    enabled = false,
                },
            },
        },
    },

    -- Floating Terminal
    {
        "numToStr/FTerm.nvim",
        lazy = true,
        opts = {
            hl = "NormalTerm",
            dimensions  = {
                height = 0.9,
                width = 0.9,
            },
        }
    },

    -- Git indicators in signcolumn
    {
        "lewis6991/gitsigns.nvim",
        event = "BufReadPre",
        opts = {
            watch_gitdir = { enable = false },
            signs = {
                add          = { text = '▎' },
                change       = { text = '▎' },
                delete       = { text = '▎' },
                topdelete    = { text = '▎' },
                changedelete = { text = '▎' },
                untracked    = { text = '▎' },
            },
        }
    },

    -- Automatically close buffers if there are more than 10, it helps with keeping
    -- LSPs performant and anything that needs to check all buffers (eg. gitsigns)
    {
        "axkirillov/hbac.nvim",
        event = "VeryLazy",
        opts = true,
    },

    {
        "chrisgrieser/nvim-recorder",
        keys = {"q"},
        opts = {
            lessNotifications = true,
        },
    },
}
