-- Incrementally select treesitter nodes
return {
    "sustech-data/wildfire.nvim",
    dependencies = "nvim-treesitter/nvim-treesitter",
    event = "VeryLazy",
    opts = {
        filetype_exclude = require("utils.filetypes").special_filetypes,
        keymaps = {
            init_selection = "<CR>",
            node_incremental = "<CR>",
            node_decremental = "<NOP>",
        },
    },
}
