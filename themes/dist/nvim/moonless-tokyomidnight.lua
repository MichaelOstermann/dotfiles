if vim.g.colors_name then
    vim.cmd("hi clear")
end

vim.g.colors_name = "moonless-tokyomidnight"
vim.opt.background = "dark"

local function hl(name, style)
    vim.api.nvim_set_hl(0, name, style)
end

local function js(name, style)
    hl(name .. ".jsx", style)
    hl(name .. ".tsx", style)
    hl(name .. ".javascript", style)
    hl(name .. ".typescript", style)
    hl(name .. ".javascriptreact", style)
    hl(name .. ".typescriptreact", style)
end

-- Neovim
hl("Character", { link = "String" })
hl("Comment", { fg = "#5b5f73" })
hl("Conceal", { link = "Comment" })
hl("Constant", { fg = "#b6724c" })
hl("CurSearch", { link = "Visual" })
hl("CursorLine", { bg = "#2d2e37" })
hl("Delimiter", { fg = "#64697f" })
hl("DiagnosticError", { fg = "#b05768" })
hl("DiagnosticHint", { fg = "#5975b1" })
hl("DiagnosticInfo", { fg = "#5975b1" })
hl("DiagnosticOk", { fg = "#347883" })
hl("DiagnosticUnderlineError", { fg = "#b05768" })
hl("DiagnosticUnderlineWarn", { fg = "#a07e4f" })
hl("DiagnosticUnnecessary", { fg = "#6d728a" })
hl("DiagnosticWarn", { fg = "#a07e4f" })
hl("Directory", { fg = "#5975b1" })
hl("Error", { fg = "#b05768" })
hl("ErrorMsg", { fg = "#b05768" })
hl("FloatBorder", { link = "WinSeparator" })
hl("FloatTitle", { fg = "#5975b1" })
hl("Folded", { link = "Comment" })
hl("Function", { fg = "#5975b1" })
hl("healthError", { fg = "#b05768" })
hl("healthSuccess", { fg = "#347883" })
hl("healthWarning", { fg = "#a07e4f" })
hl("Identifier", { fg = "#8a91af" })
hl("IncSearch", { fg = "#212127", background = "#a07e4f" })
hl("Keyword", { fg = "#866fb1" })
hl("LineNr", { fg = "#64697f" })
hl("MatchParen", { fg = "NONE" })
hl("ModeMsg", { fg = "#757a94", bg = "#212127" })
hl("MoreMsg", { fg = "#5975b1" })
hl("MsgArea", { link = "StatusLine" })
hl("Normal", { fg = "#8a91af", bg = "#212127" })
hl("NormalFloat", { link = "Normal" })
hl("NormalTerm", { fg = "#7c829e", bg = "#212127" })
hl("Operator", { link = "Keyword" })
hl("Pmenu", { fg = "#7c829e", bg = "#212127" })
hl("PmenuSel", { bg = "#363743" })
hl("PmenuThumb", { bg = "#2d2e37" })
hl("PreProc", { fg = "#5975b1" })
hl("Question", { fg = "#5975b1" })
hl("SignColumn", { link = "Normal" })
hl("Special", { link = "Keyword" })
hl("SpellBad", { link = "DiagnosticUnderlineWarn" })
hl("Statement", { link = "Keyword" })
hl("StatusLine", { fg = "#757a94", bg = "#212127", ctermfg = "white" })
hl("StatusLineNC", { link = "StatusLine", ctermfg = "black" })
hl("String", { fg = "#347883" })
hl("Substitute", { fg = "#212127", background = "#a07e4f" })
hl("Title", { fg = "" })
hl("Type", { fg = "#5b94b6" })
hl("VertSplit", { link = "WinSeparator" })
hl("Visual", { bg = "#363743" })
hl("WarningMsg", { fg = "#a07e4f" })
hl("WinBar", { fg = "#8a91af", bg = "#212127" })
hl("WinBarNC", { link = "WinBar" })
hl("WinSeparator", { fg = "#1a1a20" })

-- Terminal
vim.g.terminal_color_0 = "#505465"
vim.g.terminal_color_1 = "#b05768"
vim.g.terminal_color_2 = "#347883"
vim.g.terminal_color_3 = "#a07e4f"
vim.g.terminal_color_4 = "#5975b1"
vim.g.terminal_color_5 = "#866fb1"
vim.g.terminal_color_6 = "#5b94b6"
vim.g.terminal_color_7 = "#64697f"

vim.g.terminal_color_8 = "#505465"
vim.g.terminal_color_9 = "#b05768"
vim.g.terminal_color_10 = "#347883"
vim.g.terminal_color_11 = "#a07e4f"
vim.g.terminal_color_12 = "#5975b1"
vim.g.terminal_color_13 = "#866fb1"
vim.g.terminal_color_14 = "#5b94b6"
vim.g.terminal_color_15 = "#64697f"

-- Treesitter
hl("@attribute.css", { link = "Constant" })
hl("@boolean", { link = "Constant" })
hl("@character", { link = "String" })
hl("@character.special", { link = "Keyword" })
hl("@comment", { link = "Comment" })
hl("@comment.todo", { fg = "#b05768", bg = "#402a32" })
hl("@comment.note", { fg = "#5975b1", bg = "#2a3043" })
hl("@constant", { fg = "#8a91af" })
hl("@constant.builtin", { link = "Constant" })
hl("@constant.builtin.rust", { link = "Type" })
hl("@constant.css", { fg = "#b6724c" })
hl("@constant.elixir", { fg = "#8a91af" })
hl("@constructor.python", { link = "Function" })
hl("@function", { link = "Function" })
hl("@function.builtin", { link = "Function" })
hl("@function.macro", { link = "Function" })
hl("@keyword", { link = "Keyword" })
hl("@keyword.directive.markdown", { link = "Keyword" })
hl("@label.javascript", { link = "Keyword" })
hl("@label.markdown", { fg = "#8a91af" })
hl("@label.ruby", { link = "Comment" })
hl("@label.yaml", { fg = "#8a91af" })
hl("@markup.heading", { fg = "#5975b1" })
hl("@markup.heading.1.html", { fg = "#8a91af" })
hl("@markup.heading.2.html", { fg = "#8a91af" })
hl("@markup.heading.3.html", { fg = "#8a91af" })
hl("@markup.heading.4.html", { fg = "#8a91af" })
hl("@markup.heading.5.html", { fg = "#8a91af" })
hl("@markup.heading.6.html", { fg = "#8a91af" })
hl("@markup.heading.7.html", { fg = "#8a91af" })
hl("@markup.heading.html", { fg = "#8a91af" })
hl("@markup.italic.markdown_inline", { fg = "#866fb1", italic = true })
hl("@markup.link.label.markdown_inline", { fg = "#5975b1" })
hl("@markup.list", { link = "Delimiter" })
hl("@markup.quote.markdown", { italic = true })
hl("@markup.raw.markdown_inline", { link = "Keyword" })
hl("@markup.strikethrough.markdown_inline", { strikethrough = true })
hl("@markup.strong.markdown_inline", { fg = "#866fb1", bold = true })
hl("@module.elixir", { fg = "#8a91af" })
hl("@number", { link = "Constant" })
hl("@number.css", { link = "Constant" })
hl("@number.float.css", { link = "Constant" })
hl("@operator", { link = "Keyword" })
hl("@property", { fg = "#8a91af" })
hl("@punctuation", { link = "Delimiter" })
hl("@punctuation.delimiter.regex", { link = "Keyword" })
hl("@punctuation.special", { link = "Keyword" })
hl("@punctuation.special.markdown", { link = "Delimiter" })
hl("@string", { link = "String" })
hl("@string.css", { link = "String" })
hl("@string.documentation", { link = "Comment" })
hl("@string.escape", { link = "Keyword" })
hl("@string.special", { link = "Keyword" })
hl("@string.special.symbol", { fg = "#8a91af" })
hl("@string.special.symbol.elixir", { fg = "#8a91af" })
hl("@tag.attribute", { fg = "#a07e4f" })
hl("@tag.builtin", { link = "Keyword" })
hl("@tag.css", { link = "Keyword" })
hl("@tag.delimiter", { link = "Delimiter" })
hl("@tag.html", { link = "Keyword" })
hl("@type", { fg = "#8a91af" })
hl("@type.builtin", { link = "Type" })
hl("@type.css", { fg = "#a07e4f" })
hl("@type.definition.go", { fg = "#8a91af" })
hl("@type.prisma", { link = "Keyword" })
hl("@variable", { fg = "#8a91af" })
hl("@variable.builtin", { link = "Keyword" })
hl("@variable.parameter", { fg = "#a07e4f" })
js("@constructor", { link = "Function" })
js("@tag", { link = "Function" })

-- Flash
hl("FlashMatch", { fg = "#8a91af", bg = "#2d2e37" })
hl("FlashCurrent", { fg = "#8a91af", bg = "#2d2e37" })

-- Mason
hl("MasonHighlight", { fg = "#5975b1" })
hl("MasonHighlightBlockBold", { fg = "#212127", bg = "#5975b1" })
hl("MasonMuted", { fg = "#5b5f73" })
hl("MasonMutedBlock", { bg = "#2d2e37" })

-- Mini.clue
hl("MiniClueBorder", { link = "WinSeparator" })
hl("MiniClueDescGroup", { fg = "#5975b1" })
hl("MiniClueDescSingle", { link = "Normal" })
hl("MiniClueNextKey", { link = "Normal" })
hl("MiniClueNextKeyWithPostkeys", { fg = "#5975b1" })
hl("MiniClueSeparator", { link = "WinSeparator" })
hl("MiniClueTitle", { fg = "#5975b1" })

-- Grug-far
hl("GrugFarResultsLineColumn", { link = "LineNr" })
hl("GrugFarResultsLineNo", { link = "LineNr" })
hl("GrugFarResultsMatch", { fg = "#212127", bg = "#a07e4f" })
hl("GrugFarResultsPath", { fg = "#5975b1" })

-- MultiCursor
hl("MultiCursorCursor", { link = "Cursor" })
hl("MultiCursorVisual", { link = "Visual" })
hl("MultiCursorDisabledCursor", { link = "Visual" })
hl("MultiCursorDisabledVisual", { link = "Visual" })

-- NvimTree
hl("NvimTreeBookmarkIcon", { fg = "#5975b1" })
hl("NvimTreeEmptyFolderName", { fg = "#7c829e" })
hl("NvimTreeFileIcon", { fg = "#7c829e" })
hl("NvimTreeFolderIcon", { fg = "#7c829e" })
hl("NvimTreeFolderName", { fg = "#7c829e" })
hl("NvimTreeGitDeletedIcon", { fg = "#9e4f5f" })
hl("NvimTreeGitDirtyIcon", { fg = "#907248" })
hl("NvimTreeGitIgnoredIcon", { fg = "#5b5f73" })
hl("NvimTreeGitMergeIcon", { fg = "#b05768" })
hl("NvimTreeGitNewIcon", { fg = "#306c76" })
hl("NvimTreeGitRenamedIcon", { fg = "#907248" })
hl("NvimTreeGitStagedIcon", { fg = "#7c829e" })
hl("NvimTreeImageFile", { fg = "#7c829e" })
hl("NvimTreeNormal", { fg = "#7c829e", bg = "#212127" })
hl("NvimTreeOpenedFolderName", { fg = "#7c829e" })
hl("NvimTreeSpecialFile", { fg = "#7c829e" })
hl("NvimTreeWindowPicker", { fg = "#212127", bg = "#5975b1" })

-- Cmp
hl("CmpFloatBorder", { fg = "#1a1a20", bg = "#212127" })
hl("CmpItemAbbrMatch", { fg = "#a07e4f" })
hl("CmpItemAbbrMatchFuzzy", { fg = "#a07e4f" })

-- Telescope
hl("TelescopeBorder", { fg = "#212127" })
hl("TelescopeMatching", { fg = "#a07e4f" })
hl("TelescopeNormal", { fg = "#8a91af" })
hl("TelescopePromptCounter", { fg = "#5975b1" })
hl("TelescopePromptTitle", { fg = "#5975b1" })

-- Mini.signs
hl("MiniDiffSignAdd", { fg = "#2d5f68" })
hl("MiniDiffSignChange", { fg = "#7e6442" })
hl("MiniDiffSignDelete", { fg = "#8a4654" })

-- Egrepify
hl("EgrepifyCol", { link = "LineNr" })
hl("EgrepifyLnum", { link = "LineNr" })

-- RenderMarkdown
hl("RenderMarkdownH1Bg", { fg = "#5975b1", bg = "#262937" })
hl("RenderMarkdownH2Bg", { fg = "#5975b1", bg = "#262937" })
hl("RenderMarkdownH3Bg", { fg = "#5975b1", bg = "#262937" })
hl("RenderMarkdownH4Bg", { fg = "#5975b1", bg = "#262937" })
hl("RenderMarkdownH5Bg", { fg = "#5975b1", bg = "#262937" })
hl("RenderMarkdownH6Bg", { fg = "#5975b1", bg = "#262937" })
hl("RenderMarkdownBullet", { fg = "#64697f" })
hl("RenderMarkdownUnchecked", { fg = "#6d728a" })
hl("RenderMarkdownChecked", { fg = "#866fb1" })
hl("RenderMarkdownTodo", { fg = "#b05768" })
hl("RenderMarkdownQuote", { fg = "#5b5f73" })
-- RenderMarkdownTableHead
-- RenderMarkdownTableRow
-- RenderMarkdownTableFill
hl("RenderMarkdownInfo", { fg = "#5975b1" })
hl("RenderMarkdownSuccess", { fg = "#347883" })
hl("RenderMarkdownHint", { fg = "#5975b1" })
hl("RenderMarkdownWarn", { fg = "#a07e4f" })
hl("RenderMarkdownError", { fg = "#b05768" })
hl("RenderMarkdownQuote", { fg = "#5b5f73" })
-- RenderMarkdownLink

-- WIP CodeCompanion diffs
hl("@diff.plus.diff", { fg = "#347883" })
hl("@diff.minus.diff", { fg = "#b05768" })
hl("@string.special.path.diff", { fg = "NONE" })
hl("@markup.raw.block.markdown", { fg = "NONE" })

-- diffAdded = { fg = c.git.add },
-- diffRemoved = { fg = c.git.delete },
-- diffChanged = { fg = c.git.change },
-- diffOldFile = { fg = c.yellow },
-- diffNewFile = { fg = c.orange },
-- diffFile = { fg = c.blue },
-- diffLine = { fg = c.comment },
-- diffIndexLine = { fg = c.magenta },
-- Debug = { fg = c.orange }, --    debugging statements
-- Underlined = { underline = true }, -- (preferred) text that stands out, HTML links
-- Bold = { bold = true, fg = c.fg }, -- (preferred) any bold text
-- Italic = { italic = true, fg = c.fg }, -- (preferred) any italic text
-- Todo = { bg = c.yellow, fg = c.bg }, -- (preferred) anything that needs extra attention; mostly the keywords TODO FIXME and XXX
-- qfLineNr = { fg = c.dark5 },
-- qfFileName = { fg = c.blue },
-- ColorColumn = { bg = c.black }, -- used for the columns set with 'colorcolumn'
-- Conceal = { fg = c.dark5 }, -- placeholder characters substituted for concealed text (see 'conceallevel')
-- CursorColumn = { bg = c.bg_highlight }, -- Screen-column at the cursor, when 'cursorcolumn' is set.
-- CursorLine = { bg = c.bg_highlight }, -- Screen-line at the cursor, when 'cursorline' is set.  Low-priority if foreground (ctermfg OR guifg) is not set.
-- DiffAdd = { bg = c.diff.add }, -- diff mode: Added line |diff.txt|
-- DiffChange = { bg = c.diff.change }, -- diff mode: Changed line |diff.txt|
-- DiffDelete = { bg = c.diff.delete }, -- diff mode: Deleted line |diff.txt|
-- DiffText = { bg = c.diff.text }, -- diff mode: Changed text within a changed line |diff.txt|
-- NonText = { fg = c.dark3 }, -- '@' at the end of the window, characters from 'showbreak' and other characters that do not really exist in the text (e.g., ">" displayed when a double-wide character doesn't fit at the end of the line). See also |hl-EndOfBuffer|.
-- QuickFixLine = { bg = c.bg_visual, bold = true }, -- Current |quickfix| item in the quickfix window. Combined with |hl-CursorLine| when the cursor is there.
-- SpecialKey = { fg = c.dark3 }, -- Unprintable characters: text displayed differently from what it really is.  But not 'listchars' whitespace. |hl-Whitespace|
-- SpellBad = { sp = c.error, undercurl = true }, -- Word that is not recognized by the spellchecker. |spell| Combined with the highlighting used otherwise.
-- SpellCap = { sp = c.warning, undercurl = true }, -- Word that should start with a capital. |spell| Combined with the highlighting used otherwise.
-- SpellLocal = { sp = c.info, undercurl = true }, -- Word that is recognized by the spellchecker as one that is used in another region. |spell| Combined with the highlighting used otherwise.
-- SpellRare = { sp = c.hint, undercurl = true }, -- Word that is recognized by the spellchecker as one that is hardly ever used.  |spell| Combined with the highlighting used otherwise.
-- VisualNOS = { bg = c.bg_visual }, -- Visual mode selection when vim is "Not Owning the Selection".
-- Whitespace = { fg = c.fg_gutter }, -- "nbsp", "space", "tab" and "trail" in 'listchars'
-- WildMenu = { bg = c.bg_visual }, -- current match in 'wildmenu' completion
