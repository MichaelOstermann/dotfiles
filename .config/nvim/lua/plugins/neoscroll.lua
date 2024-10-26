-- Smooth scroll, I find the instant scrolling to be disorienting
return {
    "karb94/neoscroll.nvim",
    event = "VeryLazy",
    opts = {
        easing_function = "sine",
    },
}
