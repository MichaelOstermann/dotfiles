local au = require("utils.autocommand")
local b = require("utils.buffer")
local map = vim.keymap.set

-- Escape to normal mode in terminals
map("t", "<esc><esc>", "<c-\\><c-n>")

-- Things I keep accidentally pressing in insert mode and mess up my buffers
map("i", "<c-b>", "<nop>")
map("i", "<c-g>", "<nop>")

-- Move up/down while considering word wrap
map("n", "j", [[(v:count > 1 ? 'm`' . v:count : 'g') . 'j']], { expr = true })
map("n", "k", [[(v:count > 1 ? 'm`' . v:count : 'g') . 'k']], { expr = true })

-- Move around in msgarea
map("c", "<m-b>", "<s-left>")
map("c", "<m-f>", "<s-right>")

-- Delete word in msgarea
map("c", "<m-bs>", "<c-w>")
map("c", "<c-bs>", "<c-w>")

-- Horizontal Scrolling
map({ "n", "i", "v" }, "<S-ScrollWheelUp>", "6zh")
map({ "n", "i", "v" }, "<S-ScrollWheelDown>", "6zl")

-- Vertical Scrolling
map("n", "<c-e>", "6<c-e>")
map("n", "<c-y>", "6<c-y>")
map("i", "<c-f>", "<nop>")
map("i", "<c-b>", "<nop>")
map("i", "<c-d>", "<nop>")
map("i", "<c-u>", "<nop>")
map("i", "<c-e>", "<nop>")
map("i", "<c-y>", "<nop>")

-- Additional breakpoins
map("i", ",", ",<c-g>u")
map("i", ".", ".<c-g>u")
map("i", ";", ";<c-g>u")

-- Prevent yanking on paste
map("v", "p", "P")

-- Delete char
map("n", "<bs>", '"_dl')
map("v", "<bs>", '"_d')

-- Disable option+tab
map({ "n", "i", "v" }, "<m-tab>", "<nop>")
map({ "n", "i", "v" }, "<m-s-tab>", "<nop>")

-- Move lines up/down
map("n", "<c-down>", "<Plug>GoNMLineDown")
map("n", "<c-up>", "<Plug>GoNMLineUp")
map("x", "<c-down>", "<Plug>GoVMLineDown")
map("x", "<c-up>", "<Plug>GoVMLineUp")

-- Move treesitter nodes around
map("n", "<c-left>", lazy_call("sibling-swap", "swap_with_left"))
map("n", "<c-right>", lazy_call("sibling-swap", "swap_with_right"))

-- Indent without moving cursors
map("n", "<tab>", lazy_call("stay-in-place", "shift_right_line"))
map("x", "<tab>", lazy_call("stay-in-place", "shift_right_visual"))
map("n", "<s-tab>", lazy_call("stay-in-place", "shift_left_line"))
map("x", "<s-tab>", lazy_call("stay-in-place", "shift_left_visual"))

-- Illuminate
map("n", "<c-n>", lazy_call("illuminate", "goto_next_reference"))
map("n", "<c-p>", lazy_call("illuminate", "goto_prev_reference"))

-- Close terminals with q
au("FileType", function(args)
    vim.keymap.set("n", "q", require("FTerm").close, { buffer = args.buf })
end, { pattern = "FTerm" })

-- Frequently used stuff
map("n", "<leader>r", vim.lsp.buf.rename, { desc = "Rename" })
map("n", "<leader>R", lazy_call("grug-far", "open"), { desc = "Search & Replace" })
map("n", "<leader>h", function()
    -- Expandable hover (+/- inside the float) where TypeScript 7 is attached
    if #vim.lsp.get_clients({ bufnr = 0, name = "tsc" }) > 0 then
        return require("ts_expand_hover").hover()
    end
    vim.lsp.buf.hover({
        border = "rounded",
        silent = true,
    })
end, { desc = "Hover" })
map("n", "<leader>s", lazy_call("utils.buffer", "format_and_save"), { desc = "Format & Save" })
map("n", "<leader>j", lazy_call("treesj", "toggle"), { desc = "Split/Join" })
map("n", "<leader>t", lazy_call("FTerm", "open"), { desc = "Terminal" })
map("v", "<leader>r", function()
    -- Prefill :%s/<selection>//gcI with the cursor on the replacement
    local lines = vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos("."), { type = vim.fn.mode() })
    local pattern = table.concat(
        vim.tbl_map(function(line)
            return vim.fn.escape(line, "/\\")
        end, lines),
        "\\n"
    )
    local keys = vim.api.nvim_replace_termcodes("<esc>:%s/\\V", true, false, true)
        .. pattern
        .. vim.api.nvim_replace_termcodes("//gcI<left><left><left><left>", true, false, true)
    vim.api.nvim_feedkeys(keys, "in", false)
end, { desc = "Replace" })
map("v", "<leader>R", lazy_call("grug-far", "with_visual_selection"), { desc = "Search & Replace" })
map("n", "<leader>y", function()
    vim.fn.setreg("+", vim.fn.expand("%:p:."))
end, { desc = "Copy Path" })

-- Toggle async on the nearest parent function
map("n", "<leader>a", function()
    local parser = vim.treesitter.get_parser(0, nil, { error = false })
    if not parser then
        return
    end
    parser:parse()

    local node = b.find_node_ancestor({
        "arrow_function",
        "function_declaration",
        "function_expression",
        "method_definition",
    })
    if not node then
        return
    end

    for child in node:iter_children() do
        if child:type() == "async" then
            local start_row, start_col = child:start()
            local end_row, end_col = child:next_sibling():start()
            vim.api.nvim_buf_set_text(0, start_row, start_col, end_row, end_col, {})
            return
        end
    end

    -- Methods: after modifiers like `static`, before the name
    local target = node:type() == "method_definition" and node:field("name")[1] or node
    local start_row, start_col = target:start()
    vim.api.nvim_buf_set_text(0, start_row, start_col, start_row, start_col, { "async " })
end, { desc = "Toggle Async" })

-- NvimTree
map("n", "<leader>e", "<cmd>NvimTreeOpen<cr>", { desc = "Focus Explorer" })
map("n", "<leader>E", "<cmd>NvimTreeFindFile<cr>", { desc = "Focus File" })

-- Diagnostics
map("n", "<leader>dd", vim.lsp.buf.code_action, { desc = "Fix Diagnostic" })
map("n", "<leader>do", vim.diagnostic.open_float, { desc = "Open Diagnostic" })
map("n", "<leader>df", vim.diagnostic.goto_next, { desc = "Next Diagnostic" })
map("n", "<leader>ds", vim.diagnostic.goto_prev, { desc = "Prev Diagnostic" })

-- Git
map("n", "<leader>gg", function()
    vim.system(
        { "git", "add", vim.api.nvim_buf_get_name(0) },
        {},
        vim.schedule_wrap(function(result)
            if result.stderr then
                vim.notify(vim.trim(result.stderr), vim.log.levels.ERROR)
            end
        end)
    )
end, { desc = "Stage" })

-- Window
map("n", "<leader>c", "<c-w>c", { desc = "Close Window" })
map("n", "<leader>v", "<cmd>vsplit<cr>", { desc = "Vertical Split" })

-- Telescope
map("n", "<leader>fg", lazy_call("picker.ripgrep", "open"), { desc = "Grep" })
map("n", "<leader>fe", lazy_call("picker.eslint", "open"), { desc = "ESLint" })
map("n", "<leader>ft", lazy_call("picker.tsc", "open"), { desc = "TSC" })
map("n", "<leader>ff", lazy_call("picker.files", "open"), { desc = "Files" })
map("n", "<leader>fi", lazy_call("picker.implementations", "open"), { desc = "Implementations" })
map("n", "<leader>fd", lazy_call("picker.definitions", "open"), { desc = "Definitions" })
map("n", "<leader>fr", lazy_call("picker.references", "open"), { desc = "References" })

-- Multicursor
map("v", "I", lazy_call("multicursor-nvim", "insertVisual"))
map("v", "A", lazy_call("multicursor-nvim", "appendVisual"))
map("n", "<a-leftmouse>", lazy_call("multicursor-nvim", "handleMouse"))
map({ "n", "v" }, "<a-up>", lazy_call("multicursor-nvim", "lineAddCursor", -1))
map({ "n", "v" }, "<a-down>", lazy_call("multicursor-nvim", "lineAddCursor", 1))
map({ "n", "v" }, "~", lazy_call("multicursor-nvim", "addCursor", "*"))
map("n", "<leader>mA", lazy_call("multicursor-nvim", "matchAllAddCursors"), { desc = "Match all" })
map("n", "<leader>ma", lazy_call("multicursor-nvim", "alignCursors"), { desc = "Align" })
map({ "n", "v" }, "<leader>mt", lazy_call("multicursor-nvim", "toggleCursor"), { desc = "Toggle" })
map("n", "<leader>mr", lazy_call("multicursor-nvim", "restoreCursors"), { desc = "Restore" })
map("v", "<leader>ms", lazy_call("multicursor-nvim", "splitCursors"), { desc = "Split" })
map("v", "<leader>mm", lazy_call("multicursor-nvim", "matchCursors"), { desc = "Match" })

vim.keymap.set("n", "<esc>", function()
    local mc = require("multicursor-nvim")

    if not mc.cursorsEnabled() then
        mc.enableCursors()
    elseif mc.hasCursors() then
        mc.clearCursors()
    end
end)
