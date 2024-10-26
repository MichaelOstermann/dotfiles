-- Do not yank stuff by default, instead introduce x as a "cut" operator
return {
    "gbprod/cutlass.nvim",
    event = "VeryLazy",
    opts = {
        cut_key = "x",
        override_del = true,
        exclude = {
            "ns",
            "nS",
            "xs",
            "xS",
        },
    },
}
