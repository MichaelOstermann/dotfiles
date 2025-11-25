return {
    "numToStr/Comment.nvim",
    dependencies = "JoosepAlviste/nvim-ts-context-commentstring",
    keys = {
        "gcc",
        "gbc",
        "gco",
        "gcO",
        "gcA",
        { "gc", mode = { "v", "n" } },
        { "gb", mode = { "v", "n" } },
    },
    config = function()
        require("Comment").setup({
            pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
        })
    end,
}
