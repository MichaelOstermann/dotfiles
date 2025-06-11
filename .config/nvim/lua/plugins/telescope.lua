return {
    "nvim-telescope/telescope.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    event = "VeryLazy",
    cmd = { "Telescope" },
    config = function()
        local ignores = "!{" .. table.concat(require("utils.filetypes").rg_ignores, ",") .. "}"

        local find_command = {
            "rg",
            "--files",
            "--hidden",
            "--glob",
            ignores,
        }

        local grep_command = {
            "rg",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
            "--hidden",
            "--glob",
            ignores,
        }

        require("telescope").setup({
            defaults = {
                sorting_strategy = "ascending",
                color_devicons = false,
                layout_config = {
                    horizontal = {
                        height = { padding = 0 },
                        width = { padding = 0 },
                        preview_cutoff = 120,
                        prompt_position = "top",
                    },
                },
                vimgrep_arguments = grep_command,
            },
            pickers = {
                find_files = { find_command = find_command },
            },
        })
    end,
}
