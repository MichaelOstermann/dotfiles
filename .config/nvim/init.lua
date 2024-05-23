vim.g.loaded_gzip = 1
vim.g.loaded_man = 1
vim.g.loaded_matchit = 1
vim.g.loaded_matchparen = 1
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_remote_plugins = 1
vim.g.loaded_shada_plugin = 1
vim.g.loaded_tarPlugin = 1
vim.g.loaded_2html_plugin = 1
vim.g.loaded_tutor_mode_plugin = 1
vim.g.loaded_zipPlugin = 1

function require_lazy(require_path)
    return setmetatable({}, {
            __index = function(_, k)
            return function(...)
                return require(require_path)[k](...)
            end
        end,
    })
end

vim.cmd("colorscheme galbadia")

require("core.settings")
require("core.lazy")
require("core.autocommands")

require("mappings.base")
require("mappings.bs")
require("mappings.cc")
require("mappings.cr")
require("mappings.lt")
require("mappings.oO")
require("mappings.pairs")
require("mappings.space")
require("mappings.leader")
