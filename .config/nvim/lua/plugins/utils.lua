return {
    -- Signals implementation
    {
        "michaelostermann/nvim-signals",
        lazy = true,
    },

    -- Formatting
    {
        "stevearc/conform.nvim",
        lazy = true,
        opts = {
            formatters_by_ft = {
                lua = { "stylua" },
            },
        },
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
            signs_staged_enable = false,
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

    -- Convenient git commands.
    {
        "echasnovski/mini-git",
        version = false,
        main = "mini.git",
        event = "VeryLazy",
        config = function()
            vim.g.minigit_disable = true
            require("mini.git").setup()
        end,
    },

    -- Search & Replace panel.
    {
        "MagicDuck/grug-far.nvim",
        config = function()
            require("grug-far").setup({
                transient = true,
                windowCreationCommand = "tabnew %",
                icons = { enabled = false },
                folding = { enabled = false },
                resultLocation = { showNumberLabel = false },
                keymaps = {
                    openNextLocation = false,
                    openPrevLocation = false,
                },
            })
        end,
    },
}
