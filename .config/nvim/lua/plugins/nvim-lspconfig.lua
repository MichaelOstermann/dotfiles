return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "saghen/blink.cmp",
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
    },
    config = function()
        local lspconfig = require("lspconfig")

        require("mason").setup()
        require("mason-lspconfig").setup({
            automatic_installation = true,
            ensure_installed = {
                "eslint",
                "html",
                "jsonls",
                "rust_analyzer",
                "tailwindcss",
                "vtsls",
                "zls",
            },
        })

        local capabilities = vim.tbl_deep_extend(
            "force",
            require("blink.cmp").get_lsp_capabilities(),
            require("lsp-file-operations").default_capabilities()
        )

        local on_init = function(client)
            if client and client.server_capabilities then
                client.server_capabilities.semanticTokensProvider = nil
            end
        end

        local opts = {
            capabilities = capabilities,
            on_init = on_init,
        }

        lspconfig.html.setup(opts)
        lspconfig.tailwindcss.setup(opts)
        lspconfig.zls.setup(opts)

        lspconfig.vtsls.setup({
            capabilities = capabilities,
            on_init = on_init,
            settings = {
                typescript = {
                    updateImportsOnFileMove = { enabled = "never" },
                },
                javascript = {
                    updateImportsOnFileMove = { enabled = "never" },
                },
                vtsls = {
                    autoUseWorkspaceTsdk = true,
                    experimental = {
                        completion = {
                            enableServerSideFuzzyMatch = true,
                        },
                    },
                },
            },
        })

        lspconfig.rust_analyzer.setup({
            capabilities = capabilities,
            on_init = on_init,
            settings = {
                ["rust-analyzer"] = {
                    cargo = {
                        targetDir = true,
                    },
                    completion = {
                        postfix = {
                            enable = false,
                        },
                        callable = {
                            snippets = "none",
                        },
                    },
                },
            },
        })

        lspconfig.jsonls.setup({
            capabilities = capabilities,
            on_init = on_init,
            settings = {
                json = {
                    validate = { enable = true },
                    format = { enable = false },
                },
            },
            on_new_config = function(config)
                config.settings.json.schemas = config.settings.json.schemas or {}
                vim.list_extend(config.settings.json.schemas, require("schemastore").json.schemas())
            end,
        })

        lspconfig.eslint.setup({
            capabilities = capabilities,
            filetypes = {
                "javascript",
                "javascriptreact",
                "javascript.jsx",
                "typescript",
                "typescriptreact",
                "typescript.tsx",
                "vue",
                "html",
                "markdown",
                "json",
                "jsonc",
                "yaml",
                "toml",
                "xml",
                "gql",
                "graphql",
                "astro",
                "svelte",
                "css",
                "less",
                "scss",
                "pcss",
                "postcss",
            },
            settings = {
                useFlatConfig = true,
                -- Silent stylistic rules, but still auto fix them
                rulesCustomizations = {
                    { rule = "style/*", severity = "off", fixable = true },
                    { rule = "format/*", severity = "off", fixable = true },
                    { rule = "*-indent", severity = "off", fixable = true },
                    { rule = "*-spacing", severity = "off", fixable = true },
                    { rule = "*-spaces", severity = "off", fixable = true },
                    { rule = "*-order", severity = "off", fixable = true },
                    { rule = "*-dangle", severity = "off", fixable = true },
                    { rule = "*-newline", severity = "off", fixable = true },
                    { rule = "*quotes", severity = "off", fixable = true },
                    { rule = "*semi", severity = "off", fixable = true },
                },
            },
        })

        vim.fn.sign_define("DiagnosticSignError", { numhl = "DiagnosticSignError", priority = 10 })
        vim.fn.sign_define("DiagnosticSignWarn", { numhl = "DiagnosticSignWarn", priority = 10 })
        vim.fn.sign_define("DiagnosticSignHint", { numhl = "DiagnosticSignHint", priority = 10 })
        vim.fn.sign_define("DiagnosticSignInfo", { numhl = "DiagnosticSignInfo", priority = 10 })

        vim.diagnostic.config({
            update_in_insert = true,
            severity_sort = true,
            virtual_text = false,
            underline = { severity = { min = vim.diagnostic.severity.WARN } },
            signs = { severity = { min = vim.diagnostic.severity.WARN } },
            float = {
                focusable = true,
                border = "rounded",
                source = "always",
                header = "",
                prefix = "",
                suffix = "",
            },
        })
    end,
}
