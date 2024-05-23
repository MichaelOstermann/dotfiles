local M = {}

M.map = function(mode, lhs, rhs, opts)
    opts = opts or {}
    opts = vim.tbl_extend("force", { noremap = true }, opts)
    vim.keymap.set(mode, lhs, rhs, opts)
end

M.desc = function(desc)
    return { desc = desc }
end

M.leader = function(lhs)
    return "<leader>" .. lhs
end

M.cmd = function(cmd)
    return "<cmd>" .. cmd .. "<cr>"
end

M.expr = function(mode, lhs, rhs)
    return M.map(mode, lhs, rhs, {
        expr = true,
        noremap = true,
    })
end

return M
