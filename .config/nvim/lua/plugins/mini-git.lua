-- Convenient git commands.
return {
    "echasnovski/mini-git",
    version = false,
    main = "mini.git",
    event = "VeryLazy",
    config = function()
        vim.g.minigit_disable = true
        require("mini.git").setup()
    end,
}
