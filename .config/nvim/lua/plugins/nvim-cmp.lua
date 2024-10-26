return {
    "hrsh7th/nvim-cmp",
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-nvim-lua",
        "saadparwaiz1/cmp_luasnip",
        "L3MON4D3/LuaSnip",
    },
    event = { "InsertEnter" },
    config = function()
        local cmp = require("cmp")
        local luasnip = require("luasnip")
        local illuminate = require("illuminate")

        require("luasnip.loaders.from_vscode").lazy_load({ paths = "./snippets" })

        cmp.event:on("menu_opened", illuminate.pause)
        cmp.event:on("menu_closed", illuminate.resume)

        local check_backspace = function()
            local col = vim.fn.col(".") - 1
            return col == 0 or vim.fn.getline("."):sub(col, col):match("%s")
        end

        local excluded_trigger_characters = { " ", "<" }

        cmp.setup({
            snippet = {
                expand = function(args)
                    luasnip.lsp_expand(args.body)
                end,
            },
            sources = {
                { name = "nvim_lsp" },
                { name = "nvim_lua" },
                { name = "luasnip" },
                { name = "buffer" },
                { name = "path" },
            },
            mapping = cmp.mapping.preset.insert({
                ["<CR>"] = cmp.mapping.confirm({ select = true }),
                ["<C-u>"] = cmp.mapping.scroll_docs(-1),
                ["<C-d>"] = cmp.mapping.scroll_docs(1),
                ["<Esc>"] = cmp.mapping(function(fallback)
                    if cmp.get_active_entry() ~= nil then
                        cmp.abort()
                    else
                        fallback()
                    end
                end),
                ["<Tab>"] = cmp.mapping(function(fallback)
                    if luasnip.expandable() then
                        luasnip.expand()
                    elseif cmp.visible() then
                        cmp.select_next_item()
                    else
                        fallback()
                    end
                end),
                ["<S-Tab>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_prev_item()
                    else
                        fallback()
                    end
                end),
            }),
            completion = {
                get_trigger_characters = function(chars)
                    local new_chars = {}
                    for _, char in ipairs(chars) do
                        if not vim.list_contains(excluded_trigger_characters, char) then
                            table.insert(new_chars, char)
                        end
                    end
                    return new_chars
                end,
            },
            confirm_opts = {
                behavior = cmp.ConfirmBehavior.Replace,
                select = false,
            },
            window = {
                completion = cmp.config.window.bordered({
                    col_offset = -1,
                    winhighlight = "Normal:Pmenu,FloatBorder:CmpFloatBorder,CursorLine:PmenuSel,Search:None",
                }),
                documentation = cmp.config.window.bordered(),
            },
        })
    end,
}
