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

require("core.lazy")
require("core.settings")

require("custom.diagnostics")
require("custom.git")
require("custom.statusline")
require("custom.winbar")

require("mappings.base")
require("mappings.bs")
require("mappings.cc")
require("mappings.cr")
require("mappings.lt")
require("mappings.oO")
require("mappings.pairs")
require("mappings.space")
require("mappings.leader")
