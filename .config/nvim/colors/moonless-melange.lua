if vim.g.colors_name then
    vim.cmd("hi clear")
end

vim.g.colors_name = "moonless-melange"
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
hl("Comment", { fg = "#5f5a55" })
hl("Conceal", { link = "Comment" })
hl("Constant", { fg = "#976d47" })
hl("CurSearch", { link = "Visual" })
hl("CursorLine", { bg = "#2f2b28" })
hl("Delimiter", { fg = "#68635e" })
hl("DiagnosticError", { fg = "#D47766" })
hl("DiagnosticHint", { fg = "#8a8fad" })
hl("DiagnosticInfo", { fg = "#8a8fad" })
hl("DiagnosticOk", { fg = "#62836c" })
hl("DiagnosticUnderlineError", { fg = "#D47766" })
hl("DiagnosticUnderlineWarn", { fg = "#987d4a" })
hl("DiagnosticUnnecessary", { fg = "#716c66" })
hl("DiagnosticWarn", { fg = "#987d4a" })
hl("Directory", { fg = "#8a8fad" })
hl("Error", { fg = "#D47766" })
hl("ErrorMsg", { fg = "#D47766" })
hl("FloatBorder", { link = "WinSeparator" })
hl("FloatTitle", { fg = "#8a8fad" })
hl("Folded", { link = "Comment" })
hl("Function", { fg = "#8a8fad" })
hl("healthError", { fg = "#D47766" })
hl("healthSuccess", { fg = "#62836c" })
hl("healthWarning", { fg = "#987d4a" })
hl("Identifier", { fg = "#8f8882" })
hl("IncSearch", { fg = "#231f1d", background = "#987d4a" })
hl("Keyword", { fg = "#95718b" })
hl("LineNr", { fg = "#68635e" })
hl("MatchParen", { fg = "NONE" })
hl("ModeMsg", { fg = "#7a736e", bg = "#231f1d" })
hl("MoreMsg", { fg = "#8a8fad" })
hl("MsgArea", { link = "StatusLine" })
hl("Normal", { fg = "#8f8882", bg = "#231f1d" })
hl("NormalFloat", { link = "Normal" })
hl("NormalTerm", { fg = "#817b75", bg = "#231f1d" })
hl("Operator", { link = "Keyword" })
hl("Pmenu", { fg = "#817b75", bg = "#231f1d" })
hl("PmenuSel", { bg = "#383431" })
hl("PmenuThumb", { bg = "#2f2b28" })
hl("PreProc", { fg = "#8a8fad" })
hl("Question", { fg = "#8a8fad" })
hl("SignColumn", { link = "Normal" })
hl("Special", { link = "Keyword" })
hl("SpellBad", { link = "DiagnosticUnderlineWarn" })
hl("Statement", { link = "Keyword" })
hl("StatusLine", { fg = "#7a736e", bg = "#231f1d", ctermfg = "white" })
hl("StatusLineNC", { link = "StatusLine", ctermfg = "black" })
hl("String", { fg = "#62836c" })
hl("Substitute", { fg = "#231f1d", background = "#987d4a" })
hl("Title", { fg = "" })
hl("Type", { fg = "#5c7576" })
hl("VertSplit", { link = "WinSeparator" })
hl("Visual", { bg = "#383431" })
hl("WarningMsg", { fg = "#987d4a" })
hl("WinBar", { fg = "#8f8882", bg = "#231f1d" })
hl("WinBarNC", { link = "WinBar" })
hl("WinSeparator", { fg = "#1c1815" })

-- Terminal
vim.g.terminal_color_0 = "#544f4b"
vim.g.terminal_color_1 = "#D47766"
vim.g.terminal_color_2 = "#62836c"
vim.g.terminal_color_3 = "#987d4a"
vim.g.terminal_color_4 = "#8a8fad"
vim.g.terminal_color_5 = "#95718b"
vim.g.terminal_color_6 = "#5c7576"
vim.g.terminal_color_7 = "#68635e"

vim.g.terminal_color_8 = "#544f4b"
vim.g.terminal_color_9 = "#D47766"
vim.g.terminal_color_10 = "#62836c"
vim.g.terminal_color_11 = "#987d4a"
vim.g.terminal_color_12 = "#8a8fad"
vim.g.terminal_color_13 = "#95718b"
vim.g.terminal_color_14 = "#5c7576"
vim.g.terminal_color_15 = "#68635e"

-- Treesitter
hl("@attribute.css", { link = "Constant" })
hl("@boolean", { link = "Constant" })
hl("@character", { link = "String" })
hl("@character.special", { link = "Keyword" })
hl("@comment", { link = "Comment" })
hl("@comment.todo", { fg = "#D47766", bg = "#4b302a" })
hl("@comment.note", { fg = "#8a8fad", bg = "#37363d" })
hl("@constant", { fg = "#8f8882" })
hl("@constant.builtin", { link = "Constant" })
hl("@constant.builtin.rust", { link = "Type" })
hl("@constant.css", { fg = "#976d47" })
hl("@constant.elixir", { fg = "#8f8882" })
hl("@constructor.python", { link = "Function" })
hl("@function", { link = "Function" })
hl("@function.builtin", { link = "Function" })
hl("@function.macro", { link = "Function" })
hl("@keyword", { link = "Keyword" })
hl("@keyword.directive.markdown", { link = "Keyword" })
hl("@label.javascript", { link = "Keyword" })
hl("@label.markdown", { fg = "#8f8882" })
hl("@label.ruby", { link = "Comment" })
hl("@label.yaml", { fg = "#8f8882" })
hl("@markup.heading", { fg = "#8a8fad" })
hl("@markup.heading.1.html", { fg = "#8f8882" })
hl("@markup.heading.2.html", { fg = "#8f8882" })
hl("@markup.heading.3.html", { fg = "#8f8882" })
hl("@markup.heading.4.html", { fg = "#8f8882" })
hl("@markup.heading.5.html", { fg = "#8f8882" })
hl("@markup.heading.6.html", { fg = "#8f8882" })
hl("@markup.heading.7.html", { fg = "#8f8882" })
hl("@markup.heading.html", { fg = "#8f8882" })
hl("@markup.italic.markdown_inline", { fg = "#95718b", italic = true })
hl("@markup.link.label.markdown_inline", { fg = "#8a8fad" })
hl("@markup.list", { link = "Delimiter" })
hl("@markup.quote.markdown", { italic = true })
hl("@markup.raw.markdown_inline", { link = "Keyword" })
hl("@markup.strikethrough.markdown_inline", { strikethrough = true })
hl("@markup.strong.markdown_inline", { fg = "#95718b", bold = true })
hl("@module.elixir", { fg = "#8f8882" })
hl("@number", { link = "Constant" })
hl("@number.css", { link = "Constant" })
hl("@number.float.css", { link = "Constant" })
hl("@operator", { link = "Keyword" })
hl("@property", { fg = "#8f8882" })
hl("@punctuation", { link = "Delimiter" })
hl("@punctuation.delimiter.regex", { link = "Keyword" })
hl("@punctuation.special", { link = "Keyword" })
hl("@punctuation.special.markdown", { link = "Delimiter" })
hl("@string", { link = "String" })
hl("@string.css", { link = "String" })
hl("@string.documentation", { link = "Comment" })
hl("@string.escape", { link = "Keyword" })
hl("@string.special", { link = "Keyword" })
hl("@string.special.symbol", { fg = "#8f8882" })
hl("@string.special.symbol.elixir", { fg = "#8f8882" })
hl("@tag.attribute", { fg = "" })
hl("@tag.builtin", { link = "Keyword" })
hl("@tag.css", { link = "Keyword" })
hl("@tag.delimiter", { link = "Delimiter" })
hl("@tag.html", { link = "Keyword" })
hl("@type", { fg = "#8f8882" })
hl("@type.builtin", { link = "Type" })
hl("@type.css", { fg = "" })
hl("@type.definition.go", { fg = "#8f8882" })
hl("@type.prisma", { link = "Keyword" })
hl("@variable", { fg = "#8f8882" })
hl("@variable.builtin", { link = "Keyword" })
hl("@variable.parameter", { fg = "#987d4a" })
js("@constructor", { link = "Function" })
js("@tag", { link = "Function" })

-- Flash
hl("FlashMatch", { fg = "#8f8882", bg = "#2f2b28" })
hl("FlashCurrent", { fg = "#8f8882", bg = "#2f2b28" })

-- Mason
hl("MasonHighlight", { fg = "#8a8fad" })
hl("MasonHighlightBlockBold", { fg = "#231f1d", bg = "#8a8fad" })
hl("MasonMuted", { fg = "#5f5a55" })
hl("MasonMutedBlock", { bg = "" })

-- Mini.clue
hl("MiniClueBorder", { link = "WinSeparator" })
hl("MiniClueDescGroup", { fg = "#8a8fad" })
hl("MiniClueDescSingle", { link = "Normal" })
hl("MiniClueNextKey", { link = "Normal" })
hl("MiniClueNextKeyWithPostkeys", { fg = "#8a8fad" })
hl("MiniClueSeparator", { link = "WinSeparator" })
hl("MiniClueTitle", { fg = "#8a8fad" })

-- Grug-far
hl("GrugFarResultsLineColumn", { link = "LineNr" })
hl("GrugFarResultsLineNo", { link = "LineNr" })
hl("GrugFarResultsMatch", { fg = "#231f1d", bg = "#987d4a" })
hl("GrugFarResultsPath", { fg = "#8a8fad" })

-- MultiCursor
hl("MultiCursorCursor", { link = "Cursor" })
hl("MultiCursorVisual", { link = "Visual" })
hl("MultiCursorDisabledCursor", { link = "Visual" })
hl("MultiCursorDisabledVisual", { link = "Visual" })

-- NvimTree
hl("NvimTreeBookmarkIcon", { fg = "#8a8fad" })
hl("NvimTreeEmptyFolderName", { fg = "#817b75" })
hl("NvimTreeFileIcon", { fg = "#817b75" })
hl("NvimTreeFolderIcon", { fg = "#817b75" })
hl("NvimTreeFolderName", { fg = "#817b75" })
hl("NvimTreeGitDeletedIcon", { fg = "#be6b5c" })
hl("NvimTreeGitDirtyIcon", { fg = "#897043" })
hl("NvimTreeGitIgnoredIcon", { fg = "#5f5a55" })
hl("NvimTreeGitMergeIcon", { fg = "#D47766" })
hl("NvimTreeGitNewIcon", { fg = "#597661" })
hl("NvimTreeGitRenamedIcon", { fg = "#897043" })
hl("NvimTreeGitStagedIcon", { fg = "#897043" })
hl("NvimTreeImageFile", { fg = "#817b75" })
hl("NvimTreeNormal", { fg = "#817b75", bg = "#231f1d" })
hl("NvimTreeOpenedFolderName", { fg = "#817b75" })
hl("NvimTreeSpecialFile", { fg = "#817b75" })
hl("NvimTreeWindowPicker", { fg = "#231f1d", bg = "#8a8fad" })

-- Cmp
hl("CmpItemAbbrMatch", { fg = "#987d4a" })
hl("CmpItemAbbrMatchFuzzy", { fg = "#987d4a" })

-- Telescope
hl("TelescopeBorder", { fg = "#231f1d" })
hl("TelescopeMatching", { fg = "#987d4a" })
hl("TelescopeNormal", { fg = "#8f8882" })
hl("TelescopePromptCounter", { fg = "#8a8fad" })
hl("TelescopePromptTitle", { fg = "#8a8fad" })

-- Mini.signs
hl("MiniDiffSignAdd", { fg = "#4f6856" })
hl("MiniDiffSignChange", { fg = "#78633c" })
hl("MiniDiffSignDelete", { fg = "#a65e51" })

-- Egrepify
hl("EgrepifyCol", { link = "LineNr" })
hl("EgrepifyLnum", { link = "LineNr" })

-- RenderMarkdown
hl("RenderMarkdownH1Bg", { fg = "#8a8fad", bg = "#2e2c30" })
hl("RenderMarkdownH2Bg", { fg = "#8a8fad", bg = "#2e2c30" })
hl("RenderMarkdownH3Bg", { fg = "#8a8fad", bg = "#2e2c30" })
hl("RenderMarkdownH4Bg", { fg = "#8a8fad", bg = "#2e2c30" })
hl("RenderMarkdownH5Bg", { fg = "#8a8fad", bg = "#2e2c30" })
hl("RenderMarkdownH6Bg", { fg = "#8a8fad", bg = "#2e2c30" })
hl("RenderMarkdownBullet", { fg = "#68635e" })
hl("RenderMarkdownUnchecked", { fg = "#716c66" })
hl("RenderMarkdownChecked", { fg = "#95718b" })
hl("RenderMarkdownTodo", { fg = "#D47766" })
hl("RenderMarkdownQuote", { fg = "#5f5a55" })
-- RenderMarkdownTableHead
-- RenderMarkdownTableRow
-- RenderMarkdownTableFill
hl("RenderMarkdownInfo", { fg = "#8a8fad" })
hl("RenderMarkdownSuccess", { fg = "#62836c" })
hl("RenderMarkdownHint", { fg = "#8a8fad" })
hl("RenderMarkdownWarn", { fg = "#987d4a" })
hl("RenderMarkdownError", { fg = "#D47766" })
hl("RenderMarkdownQuote", { fg = "#5f5a55" })
-- RenderMarkdownLink

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
