return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "saghen/blink.cmp",
        "ray-x/lsp_signature.nvim",
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
    },
    config = function()
        local lspconfig = require("lspconfig")
        local signature = require("lsp_signature")
        local signals = require("utils.signals")

        local with = vim.lsp.with
        vim.lsp.with = function(a, b)
            if a == signature.signature_handler then
                return with(function(...)
                    signature.signature_handler(...)
                    signals.signature:set(signature.status_line())
                end, b)
            else
                return with(a, b)
            end
        end

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

        local capabilities = require("blink.cmp").get_lsp_capabilities()

        local on_init = function(client)
            if client and client.server_capabilities then
                client.server_capabilities.semanticTokensProvider = nil
            end
        end

        local on_attach = function(client, bufnr)
            signature.on_attach({
                bind = false,
                hint_enable = false,
                floating_window = false,
            }, bufnr)
        end

        local opts = {
            capabilities = capabilities,
            on_init = on_init,
            on_attach = on_attach,
        }

        lspconfig.html.setup(opts)
        lspconfig.rust_analyzer.setup(opts)
        lspconfig.tailwindcss.setup(opts)
        lspconfig.zls.setup(opts)

        lspconfig.vtsls.setup({
            capabilities = capabilities,
            on_init = on_init,
            on_attach = on_attach,
            settings = {
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

        lspconfig.jsonls.setup({
            capabilities = capabilities,
            on_init = on_init,
            on_attach = on_attach,
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
            on_attach = on_attach,
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

        vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
            border = "rounded",
            silent = true,
        })

        vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {})
    end,
}
