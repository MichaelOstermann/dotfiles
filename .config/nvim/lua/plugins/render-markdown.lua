-- Prettier markdown.
return {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown", "mdx", "codecompanion" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
        render_modes = { "n", "c", "t", "i" },
        sign = {
            enabled = false,
        },
        bullet = {},
        code = {
            highlight = "None",
            highlight_border = false,
            highlight_inline = "None",
        },
        heading = {
            position = "inline",
            icons = { "# ", "## ", "### ", "#### ", "##### ", "###### " },
        },
    },
}
