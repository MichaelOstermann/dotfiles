function lazy_call(require_path, method, ...)
    local args = { ... }
    return function()
        return require(require_path)[method](unpack(args))
    end
end

require("core.theme")
require("core.lazy")
require("core.settings")

require("custom.diagnostics")
require("custom.git")
require("custom.statusline")
require("custom.winbar")

require("mappings.base")
require("mappings.custom")
