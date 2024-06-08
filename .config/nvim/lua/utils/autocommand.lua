local batch_wrap = require("signals.batch_wrap")

local function au(name, callback, options)
    options = options or {}
    options.callback = batch_wrap(callback)
    vim.api.nvim_create_autocmd(name, options)
end

return au
