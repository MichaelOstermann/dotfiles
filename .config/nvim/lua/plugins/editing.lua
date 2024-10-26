return {
    -- Commenting
    {
        "numToStr/Comment.nvim",
        dependencies = "JoosepAlviste/nvim-ts-context-commentstring",
        keys = {
            "gcc",
            "gbc",
            "gco",
            "gcO",
            "gcA",
            { "gc", mode = { "v", "n" } },
            { "gb", mode = { "v", "n" } },
        },
        config = function()
            require("Comment").setup({
                pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
            })
        end,
    },

    -- Do not yank stuff by default, instead introduce x as a "cut" operator
    {
        "gbprod/cutlass.nvim",
        event = "VeryLazy",
        opts = {
            cut_key = "x",
            override_del = true,
            exclude = {
                "ns",
                "nS",
                "xs",
                "xS",
            },
        },
    },

    -- Move lines up/down
    {
        "booperlv/nvim-gomove",
        event = "VeryLazy",
        opts = { map_defaults = false, reindent = false },
    },

    -- Surround utilities
    {
        "kylechui/nvim-surround",
        event = "VeryLazy",
        opts = {
            keymaps = {
                normal = "s",
                visual = "s",
                delete = "ds",
                change = "cs",
            },
        },
    },

    -- Shortcut for :%s///gcI
    {
        "roobert/search-replace.nvim",
        cmd = "SearchReplaceSingleBufferVisualSelection",
        opts = {},
    },

    -- Move treesitter nodes around
    {
        "Wansmer/sibling-swap.nvim",
        lazy = true,
        opts = { use_default_keymaps = false },
    },

    -- Indent without moving cursors
    {
        "gbprod/stay-in-place.nvim",
        lazy = true,
        opts = true,
    },

    -- Split/join treesitter nodes
    {
        "Wansmer/treesj",
        dependencies = "nvim-treesitter/nvim-treesitter",
        lazy = true,
        opts = { use_default_keymaps = false, max_join_length = 9999 },
    },

    -- Incrementally select treesitter nodes
    {
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
    },

    -- Multiple cursors
    {
        "jake-stewart/multicursor.nvim",
        branch = "1.0",
        lazy = true,
        opts = {
            signs = false,
        },
    },
}
