-- Floating Terminal
return {
    "numToStr/FTerm.nvim",
    lazy = true,
    opts = {
        hl = "NormalTerm",
        dimensions = {
            height = 1,
            width = 1,
            x = 0,
            y = 0,
        },
        -- ESLint plugins can detect this env var and turn off some plugins if present.
        env = { NVIM = "", VIM = "" },
    },
}
