-- Surround utilities
return {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    init = function()
        vim.g.nvim_surround_no_normal_mappings = true
        vim.g.nvim_surround_no_visual_mappings = true
        vim.g.nvim_surround_no_delete_mappings = true
        vim.g.nvim_surround_no_change_mappings = true
    end,
    config = function()
        require("nvim-surround").setup()
        vim.keymap.set("n", "s", "<Plug>(nvim-surround-normal)")
        vim.keymap.set("x", "s", "<Plug>(nvim-surround-visual)")
        vim.keymap.set("n", "ds", "<Plug>(nvim-surround-delete)")
        vim.keymap.set("n", "cs", "<Plug>(nvim-surround-change)")
    end,
}
