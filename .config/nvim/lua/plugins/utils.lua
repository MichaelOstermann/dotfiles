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
        lazy = true,
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
            -- ESLint plugins can detect this env var and turn off some plugins if present.
            env = { NVIM = "", VIM = "" },
        },
    },

    -- Git indicators in signcolumn
    {
        "echasnovski/mini.diff",
        version = "*",
        event = "BufReadPre",
        opts = {
            view = {
                style = "sign",
                signs = { add = "▎", change = "▎", delete = "▎" },
            },
            mappings = {
                apply = "",
                reset = "",
                textobject = "",
                goto_first = "",
                goto_prev = "",
                goto_next = "",
                goto_last = "",
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
        event = "VeryLazy",
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

    {
        "olimorris/codecompanion.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
            "hrsh7th/nvim-cmp",
        },
        cmd = {
            "CodeCompanion",
            "CodeCompanionChat",
            "CodeCompanionToggle",
            "CodeCompanionActions",
        },
        opts = {
            strategies = {
                chat = {
                    adapter = "openai",
                },
                inline = {
                    adapter = "openai",
                },
                agent = {
                    adapter = "openai",
                },
            },
            adapters = {
                openai = function()
                    return require("codecompanion.adapters").extend("openai", {
                        env = {
                            api_key = "cmd:security find-generic-password -w -s 'OpenAI' -a 'Michael'",
                        },
                        schema = {
                            model = {
                                default = "gpt-4o",
                            },
                        },
                    })
                end,
            },
        },
    },

    -- JSON schemas for lsp.
    {
        "b0o/SchemaStore.nvim",
        lazy = true,
    },
}
