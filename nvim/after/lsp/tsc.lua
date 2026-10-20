-- TypeScript 7, installed globally (`bun i -g typescript@7`).
return {
    cmd = { "tsc", "--lsp", "--stdio" },
    -- tsc relies on the client to watch files, which nvim disables on Linux by default.
    -- Without this, diagnostics in other files go stale after a save (needs `inotify-tools`).
    capabilities = {
        workspace = { didChangeWatchedFiles = { dynamicRegistration = true } },
        -- Makes tsc report whether a hover can expand further (ts-expand-hover.nvim).
        experimental = { hoverVerbosityLevel = true },
    },
    on_init = function(client)
        client.server_capabilities.semanticTokensProvider = nil
        if client.server_capabilities.workspace then
            client.server_capabilities.workspace.fileOperations = nil
        end
    end,
}
