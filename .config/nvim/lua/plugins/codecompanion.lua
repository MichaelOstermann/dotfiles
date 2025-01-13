return {
    "olimorris/codecompanion.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-treesitter/nvim-treesitter",
    },
    opts = {
        strategies = {
            chat = {
                adapter = "anthropic",
            },
            inline = {
                adapter = "anthropic",
            },
            agent = {
                adapter = "anthropic",
            },
        },
        adapters = {
            anthropic = function()
                return require("codecompanion.adapters").extend("anthropic", {
                    env = {
                        api_key = os.getenv("ANTHROPIC_API_KEY"),
                    },
                })
            end,
            openai = function()
                return require("codecompanion.adapters").extend("openai", {
                    env = {
                        api_key = os.getenv("OPENAI_API_KEY"),
                    },
                    schema = {
                        model = {
                            default = "gpt-4o",
                        },
                    },
                })
            end,
        },
        display = {
            chat = {
                window = {
                    layout = "float",
                    height = 0.8,
                    width = 100,
                },
            },
        },
    },
}
