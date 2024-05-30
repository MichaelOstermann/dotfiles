return {
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
        end
    },
}
