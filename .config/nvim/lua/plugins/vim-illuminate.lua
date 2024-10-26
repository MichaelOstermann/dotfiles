-- Highlights all words matching the one under the cursor
return {
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
}
