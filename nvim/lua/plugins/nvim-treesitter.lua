return {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
        "davidmh/mdx.nvim",
        "windwp/nvim-ts-autotag",
    },
    lazy = false,
    build = ":TSUpdate",
    config = function()
        require("nvim-treesitter").install({
            "bash",
            "comment",
            "css",
            "diff",
            "dockerfile",
            "eex",
            "elixir",
            "git_config",
            "gitattributes",
            "gitcommit",
            "gitignore",
            "go",
            "graphql",
            "html",
            "javascript",
            "jsdoc",
            "json",
            "jsonc",
            "lua",
            "markdown",
            "markdown_inline",
            "prisma",
            "python",
            "regex",
            "ruby",
            "rust",
            "sql",
            "svelte",
            "toml",
            "tsx",
            "typescript",
            "typst",
            "vue",
            "xml",
            "yaml",
            "zig",
        })

        vim.api.nvim_create_autocmd("FileType", {
            callback = function()
                pcall(vim.treesitter.start)
            end,
        })

        require("nvim-ts-autotag").setup({
            opts = {
                enable_close = false,
            },
        })
    end,
}
