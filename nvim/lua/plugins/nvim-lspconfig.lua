return {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
        "saghen/blink.cmp",
        "mrjones2014/codesettings.nvim",
        "mason-org/mason.nvim",
        "mason-org/mason-lspconfig.nvim",
    },
    config = function()
        local capabilities = vim.tbl_deep_extend(
            "force",
            require("blink.cmp").get_lsp_capabilities(),
            require("lsp-file-operations").default_capabilities()
        )

        local before_init = function(_, config)
            local codesettings = require("codesettings")
            config = codesettings.with_local_settings(config.name, config)
        end

        local on_init = function(client)
            if client and client.server_capabilities then
                client.server_capabilities.semanticTokensProvider = nil
            end
        end

        local opts = {
            capabilities = capabilities,
            before_init = before_init,
            on_init = on_init,
        }

        vim.lsp.config("html", opts)
        vim.lsp.config("tinymist", opts)
        vim.lsp.config("zls", opts)

        vim.lsp.config("tailwindcss", {
            capabilities = capabilities,
            before_init = before_init,
            on_init = on_init,
            settings = {
                tailwindCSS = {
                    colorDecorators = false,
                },
            },
        })

        -- TypeScript 7, installed globally (`bun i -g typescript@7`).
        vim.lsp.config("tsc", {
            -- tsc relies on the client to watch files, which nvim disables on Linux by default.
            -- Without this, diagnostics in other files go stale after a save (needs `inotify-tools`).
            capabilities = vim.tbl_deep_extend("force", capabilities, {
                workspace = { didChangeWatchedFiles = { dynamicRegistration = true } },
                -- Makes tsc report whether a hover can expand further (ts-expand-hover.nvim).
                experimental = { hoverVerbosityLevel = true },
            }),
            before_init = before_init,
            cmd = { "tsc", "--lsp", "--stdio" },
            on_init = function(client)
                on_init(client)
                if client.server_capabilities.workspace then
                    client.server_capabilities.workspace.fileOperations = nil
                end
            end,
        })
        vim.lsp.enable("tsc")

        -- nvim's inotifywait watcher only skips `.git`, so it recursively watches `node_modules`,
        -- cargo's `target`, etc. (thousands of watches per registration). Skip what git ignores.
        local watchfiles = require("vim.lsp._watchfiles")
        if watchfiles._watchfunc == vim._watch.inotify then
            watchfiles._watchfunc = function(path, ...)
                local excludes = {}
                local ignored = vim.system(
                    { "git", "ls-files", "--others", "--ignored", "--exclude-standard", "--directory", "-z" },
                    { cwd = path, text = true }
                ):wait()
                if ignored.code == 0 then
                    for dir in ignored.stdout:gmatch("([^%z]+)/%z") do
                        table.insert(excludes, "@" .. vim.fs.joinpath(path, dir))
                    end
                end
                -- The inotifywait arguments are hardcoded upstream, so inject ours into the spawn.
                local system = vim.system
                vim.system = function(cmd, ...)
                    vim.system = system
                    return system(vim.list_extend(cmd, excludes), ...)
                end
                return vim._watch.inotify(path, ...)
            end
        end

        -- inotifywait complains on stderr when a watched directory is deleted (the kernel already
        -- dropped the watch), or when a new directory is gone again before it could be watched
        -- (cargo's `targetXXXXXX` temp dirs). nvim surfaces all of its stderr as an error, but
        -- both are harmless.
        local notify = vim.notify
        vim.notify = function(msg, ...)
            if type(msg) == "string" and msg:find("^inotify: ") then
                local removed = msg:find("remov%a+ watch on")
                local vanished = msg:find("Couldn't watch new directory") and msg:find("No such file or directory")
                if removed or vanished then
                    return
                end
            end
            return notify(msg, ...)
        end

        vim.lsp.config("rust_analyzer", {
            capabilities = capabilities,
            before_init = before_init,
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

        vim.lsp.config("jsonls", {
            capabilities = capabilities,
            -- The schema catalog is large, only load it once the server actually starts
            before_init = function(_, config)
                config.settings.json.schemas = require("schemastore").json.schemas()
            end,
            settings = {
                json = {
                    validate = { enable = true },
                    format = { enable = false },
                },
            },
        })

        vim.lsp.config("eslint", {
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
                -- Silent stylistic rules, but still auto fix them
                rulesCustomizations = {
                    { rule = "@stylistic/*", severity = "off", fixable = true },
                    { rule = "perfectionist/*", severity = "off", fixable = true },
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

        require("mason").setup({
            ui = {
                width = 1,
                height = 1,
            },
        })
        require("mason-lspconfig").setup({
            ensure_installed = {
                "eslint",
                "html",
                "jsonls",
                "rust_analyzer",
                "tailwindcss",
                "zls",
            },
        })
    end,
}
