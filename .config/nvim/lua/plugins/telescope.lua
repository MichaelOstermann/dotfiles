return {
    "nvim-telescope/telescope.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "fdschmidt93/telescope-egrepify.nvim",
    },
    event = "VeryLazy",
    cmd = { "Telescope" },
    config = function()
        require('telescope').setup({
            defaults = {
                sorting_strategy = "ascending",
                color_devicons = false,
                layout_config = {
                    horizontal = {
                        height = { padding = 0 },
                        width = { padding = 0 },
                        preview_cutoff = 120,
                        prompt_position = "top",
                    }
                }
            }
        })

        require('telescope').load_extension("egrepify")
    end
}
