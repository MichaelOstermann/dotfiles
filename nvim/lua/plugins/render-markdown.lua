-- Prettier markdown.
return {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown", "mdx" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
        render_modes = { "n", "c", "t" },
        sign = {
            enabled = false,
        },
        code = {
            border = "thick",
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
