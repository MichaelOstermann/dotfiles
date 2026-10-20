return {
    settings = {
        ["rust-analyzer"] = {
            cargo = {
                targetDir = true,
            },
            completion = {
                postfix = {
                    enable = false,
                },
                callable = {
                    snippets = "none",
                },
            },
        },
    },
}
