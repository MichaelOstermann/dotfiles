return {
    "olimorris/codecompanion.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-treesitter/nvim-treesitter",
    },
    opts = {
        strategies = {
            chat = {
                adapter = "gemini",
            },
            inline = {
                adapter = "gemini",
            },
            agent = {
                adapter = "gemini",
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
            gemini = function()
                return require("codecompanion.adapters").extend("gemini", {
                    env = {
                        api_key = os.getenv("GEMINI_API_KEY"),
                    },
                    schema = {
                        model = {
                            default = "gemini-2.5-pro-exp-03-25",
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
