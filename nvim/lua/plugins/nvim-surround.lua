-- Surround utilities
return {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    opts = {
        keymaps = {
            normal = "s",
            visual = "s",
            delete = "ds",
            change = "cs",
        },
    },
}
