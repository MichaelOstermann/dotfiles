return {
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
}
