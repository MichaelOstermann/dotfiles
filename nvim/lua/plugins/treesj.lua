-- Split/join treesitter nodes
return {
    "Wansmer/treesj",
    dependencies = "nvim-treesitter/nvim-treesitter",
    lazy = true,
    opts = { use_default_keymaps = false, max_join_length = 9999 },
}
