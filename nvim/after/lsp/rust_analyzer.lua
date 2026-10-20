return {
    -- Replaces lspconfig's, which passes the settings as `initializationOptions` and registers `rust-analyzer.runSingle`.
    before_init = function(_, config)
        require("codesettings").with_local_settings(config.name, config)
    end,
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
}
