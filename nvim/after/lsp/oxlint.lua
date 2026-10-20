-- Projects on @monstermann/stdlib-style: oxlint lints with the binary the project installed. It only
-- starts where its config is, so ESLint keeps the projects that still have one.

-- Silent stylistic rules, the fixes on save still apply them. Codes are `plugin(rule)`,
-- these match the rule. Formatting itself is dprint's, it reports nothing. Not `import/first`:
-- oxlint cannot fix it.
local silent_rules = {
    "^no%-duplicates$",
    "newline",
    "order",
    "sort",
    "specifier%-style$",
    "^prefer%-arrow%-callback$",
}

local function is_loud(diagnostic)
    local rule = type(diagnostic.code) == "string" and diagnostic.code:match("%((.-)%)$")
    if not rule then
        return true
    end
    for _, pattern in ipairs(silent_rules) do
        if rule:find(pattern) then
            return false
        end
    end
    return true
end

return {
    -- Without its config there is no root, and nvim would start it for the file alone.
    workspace_required = true,
    settings = {
        -- lspconfig only turns this on when a `.oxlintrc.json` mentions TypeScript, ours is `oxlint.config.ts`.
        typeAware = true,
    },
    handlers = {
        ["textDocument/publishDiagnostics"] = function(err, result, ctx)
            if result then
                result.diagnostics = vim.tbl_filter(is_loud, result.diagnostics)
            end
            return vim.lsp.diagnostic.on_publish_diagnostics(err, result, ctx)
        end,
        ["textDocument/diagnostic"] = function(err, result, ctx)
            if result and result.items then
                result.items = vim.tbl_filter(is_loud, result.items)
            end
            return vim.lsp.diagnostic.on_diagnostic(err, result, ctx)
        end,
    },
}
