return {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
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
            autotag = { enable = true },
            highlight = { enable = true },
            indent = { enable = false },
        })

        vim.treesitter.language.register("markdown", "mdx")
    end,
}
