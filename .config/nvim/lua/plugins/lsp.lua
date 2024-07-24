return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "ray-x/lsp_signature.nvim",
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
    },
    config = function()
        local cmp_nvim_lsp = require("cmp_nvim_lsp")
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
                "cssls",
                "eslint",
                "gopls",
                "graphql",
                "html",
                "jsonls",
                "prismals",
                "rust_analyzer",
                "tailwindcss",
                "taplo",
                "tsserver",
                "zls",
            },
        })

        local capabilities = vim.lsp.protocol.make_client_capabilities()
        capabilities.textDocument.completion.completionItem.snippetSupport = true
        capabilities = cmp_nvim_lsp.default_capabilities(capabilities)

        local disable_semantic_tokens = function(client)
            client.server_capabilities.semanticTokensProvider = nil
        end

        local setup_signatures = function(bufnr)
            signature.on_attach({
                bind = true,
                hint_enable = false,
                floating_window = false,
                floating_window_off_y = 0,
                floating_window_off_x = 0,
                toggle_key = "<C-s>",
                toggle_key_flip_floatwin_setting = true,
            }, bufnr)
        end

        local on_attach = function(client, bufnr)
            disable_semantic_tokens(client)
            setup_signatures(bufnr)
        end

        local opts = {
            capabilities = capabilities,
            on_attach = on_attach,
        }

        lspconfig.cssls.setup(opts)
        lspconfig.gopls.setup(opts)
        lspconfig.graphql.setup(opts)
        lspconfig.html.setup(opts)
        lspconfig.jsonls.setup(opts)
        lspconfig.prismals.setup(opts)
        lspconfig.rust_analyzer.setup(opts)
        lspconfig.tailwindcss.setup(opts)
        lspconfig.taplo.setup(opts)
        lspconfig.tsserver.setup(opts)
        lspconfig.zls.setup(opts)

        lspconfig.eslint.setup({
            capabilities = capabilities,
            on_attach = on_attach,
            settings = { useFlatConfig = true },
            filetypes = {
                "javascript",
                "javascriptreact",
                "javascript.jsx",
                "typescript",
                "typescriptreact",
                "typescript.tsx",
                "vue",
                "svelte",
                "astro",
                "html",
                "markdown",
                "json",
                "jsonc",
                "yaml",
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
