return {
    {
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
            dimensions = {
                height = 1,
                width = 1,
                x = 0,
                y = 0,
            },
        },
    },

    -- Git indicators in signcolumn
    {
        "lewis6991/gitsigns.nvim",
        event = "BufReadPre",
        opts = {
            watch_gitdir = { enable = false },
            signs = {
                add = { text = "▎" },
                change = { text = "▎" },
                delete = { text = "▎" },
                topdelete = { text = "▎" },
                changedelete = { text = "▎" },
                untracked = { text = "▎" },
            },
        },
    },

    -- Automatically close buffers if there are more than 10, it helps with keeping
    -- LSPs performant and anything that needs to check all buffers (eg. gitsigns)
    {
        "axkirillov/hbac.nvim",
        event = "VeryLazy",
        opts = true,
    },

    -- Simplify macro usage.
    {
        "chrisgrieser/nvim-recorder",
        keys = { "q" },
        opts = {
            lessNotifications = true,
        },
    },
}
