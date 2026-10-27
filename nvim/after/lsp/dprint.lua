-- Projects on @monstermann/stdlib-style: dprint formats with the binary the project installed.
return {
    workspace_required = true,
    cmd = function(dispatchers, config)
        local cmd = "dprint"
        if config and config.root_dir then
            local local_cmd = vim.fs.joinpath(config.root_dir, "node_modules/.bin/dprint")
            if vim.fn.executable(local_cmd) == 1 then
                cmd = local_cmd
            end
        end
        return vim.lsp.rpc.start({ cmd, "lsp" }, dispatchers)
    end,
    filetypes = {
        "javascript",
        "javascriptreact",
        "typescript",
        "typescriptreact",
        "json",
        "jsonc",
        "markdown",
        "mdx",
        "css",
        "scss",
        "html",
    },
}
