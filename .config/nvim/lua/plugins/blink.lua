return {
    "saghen/blink.cmp",
    version = "*",
    dependencies = { { "L3MON4D3/LuaSnip", version = "v2.*" } },
    event = { "InsertEnter" },
    config = function()
        local au = require("utils.autocommand")
        local has_multicursors = lazy_call("multicursor-nvim", "hasCursors")

        require("luasnip.loaders.from_vscode").lazy_load({
            paths = { "./snippets" },
        })

        au("User", lazy_call("illuminate", "pause"), { pattern = "BlinkCmpMenuOpen" })
        au("User", lazy_call("illuminate", "resume"), { pattern = "BlinkCmpMenuClose" })

        require("blink.cmp").setup({
            enabled = function()
                local mc = require("multicursor-nvim")
                return vim.bo.buftype ~= "prompt" and vim.b.completion ~= false and not has_multicursors()
            end,
            snippets = { preset = "luasnip" },
            completion = {
                list = {
                    selection = {
                        preselect = true,
                        auto_insert = true,
                    },
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
                cmdline = {},
                default = { "lsp", "path", "snippets", "buffer", "codecompanion" },
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
                },
            },
            keymap = {
                ["<CR>"] = { "accept", "fallback" },
                ["<Esc>"] = { "cancel", "fallback" },
                ["<C-n>"] = { "select_next", "show" },
                ["<C-p>"] = { "select_prev" },
                ["<Down>"] = { "select_next", "fallback" },
                ["<Up>"] = { "select_prev", "fallback" },
                ["<C-u>"] = { "scroll_documentation_up", "fallback" },
                ["<C-d>"] = { "scroll_documentation_down", "fallback" },
                ["<Tab>"] = {
                    function(cmp)
                        local item = cmp.get_selected_item()
                        if item and item.source_id == "snippets" then
                            return cmp.accept()
                        end
                    end,
                    "fallback",
                },
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
