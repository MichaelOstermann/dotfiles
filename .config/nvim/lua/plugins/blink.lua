return {
    "saghen/blink.cmp",
    version = "*",
    dependencies = {
        { "L3MON4D3/LuaSnip", version = "v2.*" },
        "disrupted/blink-cmp-conventional-commits",
    },
    event = { "InsertEnter" },
    config = function()
        local au = require("utils.autocommand")

        require("luasnip.loaders.from_vscode").lazy_load({
            paths = { "./snippets" },
        })

        au("User", lazy_call("illuminate", "pause"), { pattern = "BlinkCmpMenuOpen" })
        au("User", lazy_call("illuminate", "resume"), { pattern = "BlinkCmpMenuClose" })

        require("blink.cmp").setup({
            snippets = { preset = "luasnip" },
            completion = {
                list = {
                    selection = {
                        auto_insert = true,
                        preselect = function(ctx)
                            return ctx.mode ~= "cmdline"
                        end,
                    },
                },
                accept = {
                    auto_brackets = { enabled = false },
                },
                menu = {
                    border = "rounded",
                },
                documentation = {
                    auto_show = true,
                    window = { border = "rounded" },
                },
            },
            sources = {
                default = {
                    "conventional_commits",
                    "lsp",
                    "path",
                    "snippets",
                    "buffer",
                },
                providers = {
                    snippets = {
                        name = "Snippets",
                        module = "blink.cmp.sources.snippets",
                        score_offset = 100,
                        min_keyword_length = 2,
                    },
                    buffer = {
                        opts = {
                            get_bufnrs = function()
                                return vim.tbl_filter(function(bufnr)
                                    return vim.bo[bufnr].buftype == ""
                                end, vim.api.nvim_list_bufs())
                            end,
                        },
                    },
                    conventional_commits = {
                        name = "Conventional Commits",
                        module = "blink-cmp-conventional-commits",
                        enabled = function()
                            return vim.bo.filetype == "gitcommit"
                        end,
                    },
                },
            },
            keymap = {
                ["<C-n>"] = { "select_next", "show" },
                ["<C-p>"] = { "select_prev" },
                ["<Down>"] = { "select_next", "fallback" },
                ["<Up>"] = { "select_prev", "fallback" },
                ["<C-u>"] = { "scroll_documentation_up", "fallback" },
                ["<C-d>"] = { "scroll_documentation_down", "fallback" },
                -- https://github.com/Saghen/blink.cmp/issues/547
                ["<Esc>"] = {
                    "cancel",
                    function(cmp)
                        if vim.fn.getcmdtype() ~= "" then
                            vim.api.nvim_feedkeys(
                                vim.api.nvim_replace_termcodes("<C-c>", true, true, true),
                                "n",
                                true
                            )
                            return true
                        end
                    end,
                    "fallback",
                },
                ["<CR>"] = {
                    function()
                        if require("minuet.virtualtext").action.is_visible() then
                            require("minuet.virtualtext").action.accept()
                            return true
                        end
                    end,
                    "accept",
                    "fallback",
                },
                ["<C-a>"] = {
                    function()
                        require("minuet.virtualtext").action.next()
                    end,
                },
                ["<Tab>"] = { "fallback" },
                ["<S-Tab>"] = { "fallback" },
            },
            appearance = {
                kind_icons = {
                    Array = "󰅪",
                    Class = "",
                    Color = "󰏘",
                    Constant = "󰏿",
                    Constructor = "",
                    Enum = "",
                    EnumMember = "",
                    Event = "",
                    Field = "󰜢",
                    File = "󰈙",
                    Folder = "󰉋",
                    Function = "󰆧",
                    Interface = "",
                    Keyword = "󰌋",
                    Method = "󰆧",
                    Module = "",
                    Operator = "󰆕",
                    Property = "󰜢",
                    Reference = "󰈇",
                    Snippet = "",
                    Struct = "",
                    Text = "",
                    TypeParameter = "",
                    Unit = "",
                    Value = "",
                    Variable = "󰀫",
                },
            },
        })
    end,
}
