function require_lazy(require_path)
    return setmetatable({}, {
        __index = function(_, k)
            return function(...)
                return require(require_path)[k](...)
            end
        end,
    })
end

vim.cmd("colorscheme moonless-tokyonight")

require("core.lazy")
require("core.settings")

require("custom.diagnostics")
require("custom.git")
require("custom.statusline")
require("custom.winbar")

require("mappings.base")
require("mappings.custom")
require("mappings.leader")
