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
            opts = {
                show_defaults = false,
            },
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
                    width = 80,
                    opts = {
                        number = false,
                    },
                },
            },
        },
    },
}
