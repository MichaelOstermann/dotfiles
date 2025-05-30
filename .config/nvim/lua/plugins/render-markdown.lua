-- Prettier markdown.
return {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown", "mdx", "codecompanion" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
        render_modes = { "n", "c", "t" },
        sign = {
            enabled = false,
        },
        code = {
            highlight = "None",
            highlight_border = false,
            highlight_inline = "None",
        },
        heading = {
            render_modes = { "i" },
            position = "inline",
            icons = { "# ", "## ", "### ", "#### ", "##### ", "###### " },
        },
    },
}
