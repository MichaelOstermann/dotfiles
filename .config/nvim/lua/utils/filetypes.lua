local M = {}

M.special_filetypes = {
    "help",
    "cmp_docs",
    "cmp_menu",
    "prompt",
    "TelescopePrompt",
    "NvimTree",
    "grug-far",
}

M.special_buftypes = {
    "nofile",
    "prompt",
    "help",
    "quickfix",
    "terminal",
}

M.prose_filetypes = {
    "txt",
    "gitcommit",
    "markdown",
    "mdx",
}

return M
