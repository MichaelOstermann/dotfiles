return {
    "milanglacier/minuet-ai.nvim",
    lazy = true,
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
        require("minuet").setup({
            provider = "claude",
            provider_options = {
                claude = {
                    api_key = "ANTHROPIC_API_KEY",
                },
                openai = {
                    api_key = "OPENAI_API_KEY",
                },
            },
        })
    end,
}
