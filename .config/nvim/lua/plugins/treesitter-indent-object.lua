return {
    "kiyoon/treesitter-indent-object.nvim",
    keys = {
        {
            "ai",
            function()
                require("treesitter_indent_object.textobj").select_indent_outer(true)
            end,
            mode = { "x", "o" },
        },
        {
            "ii",
            function()
                require("treesitter_indent_object.textobj").select_indent_inner(true, "V")
            end,
            mode = { "x", "o" },
        },
    },
}
