return {
    -- Commenting
    {
        "numToStr/Comment.nvim",
        dependencies = "JoosepAlviste/nvim-ts-context-commentstring",
        keys = {
            'gcc',
            'gbc',
            'gco',
            'gcO',
            'gcA',
            { 'gc', mode = {'v', 'n'} },
            { 'gb', mode = {'v', 'n'} },
        },
        config = function()
            require('Comment').setup({
                pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
            })
        end
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
        opts = { use_default_keymaps = false },
    },

    -- Incrementally select treesitter nodes
    {
        "sustech-data/wildfire.nvim",
        dependencies = "nvim-treesitter/nvim-treesitter",
        keys = { "<cr>" },
        opts = true,
    },
}
