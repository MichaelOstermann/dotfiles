return {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
        "davidmh/mdx.nvim",
        "windwp/nvim-ts-autotag",
    },
    lazy = false,
    build = function()
        pcall(require("nvim-treesitter.install").update({ with_sync = true }))
    end,
    config = function()
        require("nvim-treesitter.configs").setup({
            ensure_installed = {
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
                "vue",
                "xml",
                "yaml",
                "zig",
            },
            highlight = { enable = true },
            indent = { enable = false },
        })

        require("nvim-ts-autotag").setup({
            opts = {
                enable_close = false,
            },
        })

        require("mdx").setup()
    end,
}
