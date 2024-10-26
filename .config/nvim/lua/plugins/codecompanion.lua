-- AI utils
return {
    "olimorris/codecompanion.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-treesitter/nvim-treesitter",
        "hrsh7th/nvim-cmp",
    },
    cmd = {
        "CodeCompanion",
        "CodeCompanionChat",
        "CodeCompanionToggle",
        "CodeCompanionActions",
    },
    opts = {
        strategies = {
            chat = {
                adapter = "openai",
            },
            inline = {
                adapter = "openai",
            },
            agent = {
                adapter = "openai",
            },
        },
        adapters = {
            openai = function()
                return require("codecompanion.adapters").extend("openai", {
                    env = {
                        api_key = "cmd:security find-generic-password -w -s 'OpenAI' -a 'Michael'",
                    },
                    schema = {
                        model = {
                            default = "gpt-4o",
                        },
                    },
                })
            end,
        },
    },
}
