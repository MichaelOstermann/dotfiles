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
        },
    },

    -- Multiple cursors
    {
        "jake-stewart/multicursor.nvim",
        branch = "1.0",
        config = function()
            local mc = require("multicursor-nvim")

            mc.setup({
                signs = false,
            })

            -- Add a cursor and jump to the next word under cursor.
            vim.keymap.set({ "n", "v" }, "<c-n>", function()
                mc.addCursor("*")
            end)

            -- Jump to the next word under cursor but do not add a cursor.
            vim.keymap.set({ "n", "v" }, "<c-s>", function()
                mc.skipCursor("*")
            end)

            vim.keymap.set("n", "<esc>", function()
                if not mc.cursorsEnabled() then
                    mc.enableCursors()
                elseif mc.hasCursors() then
                    mc.clearCursors()
                else
                    -- Default <esc> handler.
                end
            end)

            vim.keymap.set("v", "I", mc.insertVisual)
            vim.keymap.set("v", "A", mc.appendVisual)
            vim.keymap.set("n", "<leader>ma", mc.alignCursors, { desc = "Align" })
            vim.keymap.set("v", "<leader>ms", mc.splitCursors, { desc = "Split" })
            vim.keymap.set("v", "<leader>mm", mc.matchCursors, { desc = "Match" })
            vim.keymap.set({ "n", "v" }, "<leader>mx", mc.deleteCursor, { desc = "Delete cursor" })


            vim.api.nvim_set_hl(0, "MultiCursorCursor", { link = "Cursor" })
            vim.api.nvim_set_hl(0, "MultiCursorVisual", { link = "Visual" })
            vim.api.nvim_set_hl(0, "MultiCursorDisabledCursor", { link = "Visual" })
            vim.api.nvim_set_hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
        end,
    },
}
