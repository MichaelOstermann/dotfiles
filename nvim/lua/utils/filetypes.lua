local M = {}

M.special_filetypes = {
    "help",
    "qf",
    "cmp_docs",
    "cmp_menu",
    "prompt",
    "gitcommit",
    "NvimTree",
    "grug-far",
    "mason",
    "Custom",
}

M.special_buftypes = {
    "nofile",
    "prompt",
    "help",
    "quickfix",
    "terminal",
}

M.rg_ignores = {
    "**/.DS_Store",
    "**/.eslintcache",
    "**/.git/**",
    "**/build/**",
    "**/cache/**",
    "**/dist/**",
    "**/node_modules/**",
    "**/bun.lock",
    "**/Cargo.lock",
}

return M
