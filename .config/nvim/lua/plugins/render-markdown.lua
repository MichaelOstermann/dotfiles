-- Prettier markdown.
return {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown", "mdx", "codecompanion" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
        sign = {
            enabled = false,
        },
        code = {
            style = "none",
        },
    },
}
