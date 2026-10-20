return {
    -- Replaces lspconfig's, which sets `editor.tabSize`.
    before_init = function(_, config)
        require("codesettings").with_local_settings(config.name, config)
    end,
    settings = {
        tailwindCSS = {
            colorDecorators = false,
        },
    },
}
