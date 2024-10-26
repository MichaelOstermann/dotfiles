-- Not a huge fan of interacting with vim.ui.select via numbers.
return {
    "stevearc/dressing.nvim",
    opts = {
        input = { enabled = false },
        select = {
            backend = { "builtin" },
            builtin = {
                show_numbers = false,
                mappings = {
                    q = "Close",
                },
            },
        },
    },
}
