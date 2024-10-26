-- Automatically close buffers if there are more than 10, it helps with keeping
-- LSPs performant and anything that needs to check all buffers (eg. gitsigns)
return {
    "axkirillov/hbac.nvim",
    event = "VeryLazy",
    opts = true,
}
