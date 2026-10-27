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
        -- Every server, merged under lspconfig's `lsp/<server>.lua` and our `after/lsp/<server>.lua`. A server whose
        -- file sets `before_init` or `on_init` replaces these.
        vim.lsp.config("*", {
            capabilities = require("blink.cmp").get_lsp_capabilities(),
            before_init = function(_, config)
                require("codesettings").with_local_settings(config.name, config)
            end,
            on_init = function(client)
                client.server_capabilities.semanticTokensProvider = nil
            end,
        })
        vim.lsp.enable({ "tsc", "oxlint", "dprint" })

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
