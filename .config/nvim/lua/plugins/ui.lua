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
                    { mode = "n", keys = "<Leader>" },
                    { mode = "v", keys = "<Leader>" },
                },
                clues = {
                    miniclue.gen_clues.builtin_completion(),
                    { mode = "n", keys = "<Leader>f", desc = "+find" },
                    { mode = "n", keys = "<Leader>g", desc = "+git" },
                    { mode = "n", keys = "<Leader>c", desc = "+quickfix" },
                    { mode = "n", keys = "<Leader>m", desc = "+multicursor" },

                    { mode = "n", keys = "<Leader>w", desc = "+windows" },
                    { mode = "n", keys = "<Leader>w+", postkeys = "<Leader>w" },
                    { mode = "n", keys = "<Leader>w-", postkeys = "<Leader>w" },

                    { mode = "n", keys = "<Leader>p", desc = "+pomodoro" },
                    { mode = "n", keys = "<Leader>ps", desc = "+session" },
                    { mode = "n", keys = "<Leader>pb", desc = "+break" },
                },
            })
        end,
    },

    -- Prettier markdown.
    {
        "MeanderingProgrammer/render-markdown.nvim",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        opts = {
            sign = {
                enabled = false,
            },
            code = {
                style = "none",
            },
        },
    },

    -- Smooth scroll, I find the instant scrolling to be disorienting
    {
        "karb94/neoscroll.nvim",
        event = "VeryLazy",
        opts = {
            easing_function = "sine",
        },
    },

    -- Highlights all words matching the one under the cursor
    {
        "RRethy/vim-illuminate",
        event = "VeryLazy",
        config = function()
            local illuminate = require("illuminate")
            illuminate.configure({
                filetypes_denylist = require("utils.filetypes").special_filetypes,
                modes_allowlist = { "n", "i" },
                providers = { "regex" },
                min_count_to_highlight = 2,
                large_file_cutoff = 5000,
            })
        end,
    },
}
