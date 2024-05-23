return {
    {
        "nvim-tree/nvim-tree.lua",
        cmd = {
            "NvimTreeOpen",
            "NvimTreeFindFile",
            "NvimTreeClose",
            "NvimTreeResize",
        },
        opts = {
            hijack_cursor = true,
            auto_reload_on_write = false,
            system_open = {
                cmd = "open",
                args = { "--reveal" },
            },
            filesystem_watchers = {
                enable = false,
            },
            view = {
                width = 35,
                signcolumn = "auto",
            },
            actions = {
                open_file = { resize_window = false },
                remove_file = { close_window = false },
            },
            filters = {
                dotfiles = false,
                git_ignored = false,
                custom = {
                    "^\\.DS_Store",
                    "^\\.git$",
                },
            },
            renderer = {
                highlight_git = true,
                root_folder_label = false,
                special_files = {},
                icons = {
                    show = {
                        git = false,
                        modified = false,
                        file = false,
                        folder = false,
                    },
                    glyphs = {
                        default = "󰧮",
                        folder = {
                            default = "",
                            open = ""
                        }
                    }
                },
            },
            on_attach = function(bufnr)
                local api = require('nvim-tree.api')
                local git = require("utils.git")
                local n = require("nvim-tree.api").events

                local opts = { buffer = bufnr, noremap = true, silent = true, nowait = true }

                require("utils.nvimtree").reload = api.tree.reload

                vim.keymap.set("n", "<Esc>", "<c-w><c-p>", opts)
                vim.keymap.set("n", "<2-LeftMouse>", api.node.open.edit, opts)
                vim.keymap.set("n", "<Right>", api.node.open.edit, opts)
                vim.keymap.set("n", "<Left>", api.node.navigate.parent_close, opts)

                vim.keymap.set("n", "<CR>", api.node.open.edit, opts)
                vim.keymap.set("n", "<BS>", api.node.navigate.parent_close, opts)

                vim.keymap.set("n", "l", api.node.open.edit, opts)
                vim.keymap.set("n", "h", api.node.navigate.parent_close, opts)

                vim.keymap.set("n", "<Tab>", api.node.open.preview, opts)

                vim.keymap.set("n", "H", api.node.navigate.parent, opts)
                vim.keymap.set("n", "J", api.node.navigate.sibling.next, opts)
                vim.keymap.set("n", "K", api.node.navigate.sibling.prev, opts)

                vim.keymap.set("n", "W", api.tree.collapse_all, opts)
                vim.keymap.set("n", "s", api.node.run.system, opts)

                vim.keymap.set("n", "a", api.fs.create, opts)
                vim.keymap.set("n", "d", api.fs.trash, opts)
                vim.keymap.set("n", "c", api.fs.copy.node, opts)
                vim.keymap.set("n", "x", api.fs.cut, opts)
                vim.keymap.set("n", "p", api.fs.paste, opts)
                vim.keymap.set("n", "e", api.fs.rename_basename, opts)
                vim.keymap.set("n", "r", api.fs.rename, opts)
                vim.keymap.set("n", "y", api.fs.copy.relative_path, opts)
                vim.keymap.set("n", "Y", api.fs.copy.absolute_path, opts)

                vim.keymap.set("n", "m", api.marks.toggle, opts)
                vim.keymap.set("n", "bd", api.marks.bulk.trash, opts)
                vim.keymap.set("n", "bm", api.marks.bulk.move, opts)

                -- Refresh statusbars/nvimtree/gitsigns when I do stuff in nvimtree
                for _, event in ipairs({
                    n.Event.NodeRenamed,
                    n.Event.FileCreated,
                    n.Event.FileRemoved,
                    n.Event.FolderCreated,
                    n.Event.FolderRemoved,
                }) do
                    n.subscribe(event, git.refresh)
                end
            end
        }
    }
}
