-- Search & Replace panel.
return {
    "MagicDuck/grug-far.nvim",
    event = "VeryLazy",
    config = function()
        require("grug-far").setup({
            transient = true,
            windowCreationCommand = "tabnew %",
            icons = { enabled = false },
            folding = { enabled = false },
            resultLocation = { showNumberLabel = false },
            keymaps = {
                openNextLocation = false,
                openPrevLocation = false,
            },
        })
    end,
}
