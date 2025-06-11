-- Similar to which-key, but I prefer mini's take on it + it supports hydra-like submodes
return {
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
                { mode = "n", keys = "<Leader>m", desc = "+multicursor" },
                { mode = "n", keys = "<Leader>d", desc = "+diagnostic" },
                { mode = "n", keys = "<Leader>a", desc = "+ai" },

                { mode = "n", keys = "<Leader>w", desc = "+windows" },
                { mode = "n", keys = "<Leader>w+", postkeys = "<Leader>w" },
                { mode = "n", keys = "<Leader>w-", postkeys = "<Leader>w" },
            },
        })
    end,
}
