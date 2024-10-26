-- Git indicators in signcolumn
return {
    "echasnovski/mini.diff",
    version = "*",
    event = "BufReadPre",
    opts = {
        view = {
            style = "sign",
            signs = { add = "▎", change = "▎", delete = "▎" },
        },
        mappings = {
            apply = "",
            reset = "",
            textobject = "",
            goto_first = "",
            goto_prev = "",
            goto_next = "",
            goto_last = "",
        },
    },
}
