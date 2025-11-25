return {
    "Goose97/timber.nvim",
    version = "*",
    event = "VeryLazy",
    config = function()
        require("timber").setup({
            keymaps = {
                insert_log_below = "<Leader>l",
            },
            default_keymaps_enabled = false,
            highlight = {
                on_insert = false,
                on_add_to_batch = false,
                on_summary_show_entry = false,
            },
            log_watcher = {
                enabled = false,
            },
            log_summary = {
                default_keymaps_enabled = false,
            },
        })
    end,
}
