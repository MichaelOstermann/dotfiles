local M = {}

M.special_filetypes = {
    "help",
    "qf",
    "cmp_docs",
    "cmp_menu",
    "prompt",
    "TelescopePrompt",
    "NvimTree",
    "grug-far",
    "mason",
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
    "*.tsbuildinfo",
}

return M
