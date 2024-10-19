if vim.g.colors_name then
    vim.cmd("hi clear")
end

vim.g.colors_name = "moonless-tokyonight"
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
hl("Comment", { fg = "#4d5579" })
hl("Conceal", { link = "Comment" })
hl("Constant", { fg = "#a36747" })
hl("CurSearch", { link = "Visual" })
hl("CursorLine", { bg = "#282a3a" })
hl("Delimiter", { fg = "#555e86" })
hl("DiagnosticError", { fg = "#b05669" })
hl("DiagnosticHint", { fg = "#6789d0" })
hl("DiagnosticInfo", { fg = "#6789d0" })
hl("DiagnosticOk", { fg = "#69884b" })
hl("DiagnosticUnderlineError", { fg = "#b05669" })
hl("DiagnosticUnderlineWarn", { fg = "#907149" })
hl("DiagnosticUnnecessary", { fg = "#5c6692" })
hl("DiagnosticWarn", { fg = "#907149" })
hl("Directory", { fg = "#6789d0" })
hl("Error", { fg = "#b05669" })
hl("ErrorMsg", { fg = "#b05669" })
hl("FloatBorder", { link = "WinSeparator" })
hl("FloatTitle", { fg = "#6789d0" })
hl("Folded", { link = "Comment" })
hl("Function", { fg = "#6789d0" })
hl("healthError", { fg = "#b05669" })
hl("healthSuccess", { fg = "#69884b" })
hl("healthWarning", { fg = "#907149" })
hl("Identifier", { fg = "#7481B9" })
hl("IncSearch", { fg = "#1F2029", background = "#907149" })
hl("Keyword", { fg = "#866fb1" })
hl("LineNr", { fg = "#555e86" })
hl("MatchParen", { fg = "NONE" })
hl("ModeMsg", { fg = "#636d9c", bg = "#1F2029" })
hl("MoreMsg", { fg = "#6789d0" })
hl("MsgArea", { link = "StatusLine" })
hl("Normal", { fg = "#7481B9", bg = "#1F2029" })
hl("NormalFloat", { link = "Normal" })
hl("NormalTerm", { fg = "#6974a6", bg = "#1F2029" })
hl("Operator", { link = "Keyword" })
hl("Pmenu", { fg = "#6974a6", bg = "#1F2029" })
hl("PmenuSel", { bg = "#2f3346" })
hl("PmenuThumb", { bg = "#282a3a" })
hl("PreProc", { fg = "#6789d0" })
hl("Question", { fg = "#6789d0" })
hl("SignColumn", { link = "Normal" })
hl("Special", { link = "Keyword" })
hl("SpellBad", { link = "DiagnosticUnderlineWarn" })
hl("Statement", { link = "Keyword" })
hl("StatusLine", { fg = "#636d9c", bg = "#1F2029", ctermfg = "white" })
hl("StatusLineNC", { link = "StatusLine", ctermfg = "black" })
hl("String", { fg = "#69884b" })
hl("Substitute", { fg = "#1F2029", background = "#907149" })
hl("Title", { fg = "" })
hl("Type", { fg = "#51909f" })
hl("VertSplit", { link = "WinSeparator" })
hl("Visual", { bg = "#2f3346" })
hl("WarningMsg", { fg = "#907149" })
hl("WinBar", { fg = "#7481B9", bg = "#1F2029" })
hl("WinBarNC", { link = "WinBar" })
hl("WinSeparator", { fg = "#181921" })

-- Terminal
vim.g.terminal_color_0 = "#454c6b"
vim.g.terminal_color_1 = "#b05669"
vim.g.terminal_color_2 = "#69884b"
vim.g.terminal_color_3 = "#907149"
vim.g.terminal_color_4 = "#6789d0"
vim.g.terminal_color_5 = "#866fb1"
vim.g.terminal_color_6 = "#51909f"
vim.g.terminal_color_7 = "#555e86"

vim.g.terminal_color_8 = "#454c6b"
vim.g.terminal_color_9 = "#b05669"
vim.g.terminal_color_10 = "#69884b"
vim.g.terminal_color_11 = "#907149"
vim.g.terminal_color_12 = "#6789d0"
vim.g.terminal_color_13 = "#866fb1"
vim.g.terminal_color_14 = "#51909f"
vim.g.terminal_color_15 = "#555e86"

-- Treesitter
hl("@attribute.css", { link = "Constant" })
hl("@boolean", { link = "Constant" })
hl("@character", { link = "String" })
hl("@character.special", { link = "Keyword" })
hl("@comment", { link = "Comment" })
hl("@comment.todo", { fg = "#b05669", bg = "#3f2933" })
hl("@comment.note", { fg = "#6789d0", bg = "#2c354c" })
hl("@constant", { fg = "#7481B9" })
hl("@constant.builtin", { link = "Constant" })
hl("@constant.builtin.rust", { link = "Type" })
hl("@constant.css", { fg = "#a36747" })
hl("@constant.elixir", { fg = "#7481B9" })
hl("@constructor.python", { link = "Function" })
hl("@function", { link = "Function" })
hl("@function.builtin", { link = "Function" })
hl("@function.macro", { link = "Function" })
hl("@keyword", { link = "Keyword" })
hl("@keyword.directive.markdown", { link = "Keyword" })
hl("@label.javascript", { link = "Keyword" })
hl("@label.markdown", { fg = "#7481B9" })
hl("@label.ruby", { link = "Comment" })
hl("@label.yaml", { fg = "#7481B9" })
hl("@markup.heading", { fg = "#6789d0" })
hl("@markup.heading.1.html", { fg = "#7481B9" })
hl("@markup.heading.2.html", { fg = "#7481B9" })
hl("@markup.heading.3.html", { fg = "#7481B9" })
hl("@markup.heading.4.html", { fg = "#7481B9" })
hl("@markup.heading.5.html", { fg = "#7481B9" })
hl("@markup.heading.6.html", { fg = "#7481B9" })
hl("@markup.heading.7.html", { fg = "#7481B9" })
hl("@markup.heading.html", { fg = "#7481B9" })
hl("@markup.italic.markdown_inline", { fg = "#866fb1", italic = true })
hl("@markup.link.label.markdown_inline", { fg = "#6789d0" })
hl("@markup.list", { link = "Delimiter" })
hl("@markup.quote.markdown", { italic = true })
hl("@markup.raw.markdown_inline", { link = "Keyword" })
hl("@markup.strikethrough.markdown_inline", { strikethrough = true })
hl("@markup.strong.markdown_inline", { fg = "#866fb1", bold = true })
hl("@module.elixir", { fg = "#7481B9" })
hl("@number", { link = "Constant" })
hl("@number.css", { link = "Constant" })
hl("@number.float.css", { link = "Constant" })
hl("@operator", { link = "Keyword" })
hl("@property", { fg = "#7481B9" })
hl("@punctuation", { link = "Delimiter" })
hl("@punctuation.delimiter.regex", { link = "Keyword" })
hl("@punctuation.special", { link = "Keyword" })
hl("@punctuation.special.markdown", { link = "Delimiter" })
hl("@string", { link = "String" })
hl("@string.css", { link = "String" })
hl("@string.documentation", { link = "Comment" })
hl("@string.escape", { link = "Keyword" })
hl("@string.special", { link = "Keyword" })
hl("@string.special.symbol", { fg = "#7481B9" })
hl("@string.special.symbol.elixir", { fg = "#7481B9" })
hl("@tag.attribute", { fg = "" })
hl("@tag.builtin", { link = "Keyword" })
hl("@tag.css", { link = "Keyword" })
hl("@tag.delimiter", { link = "Delimiter" })
hl("@tag.html", { link = "Keyword" })
hl("@type", { fg = "#7481B9" })
hl("@type.builtin", { link = "Type" })
hl("@type.css", { fg = "" })
hl("@type.definition.go", { fg = "#7481B9" })
hl("@type.prisma", { link = "Keyword" })
hl("@variable", { fg = "#7481B9" })
hl("@variable.builtin", { link = "Keyword" })
hl("@variable.parameter", { fg = "#907149" })
js("@constructor", { link = "Function" })
js("@tag", { link = "Function" })

-- Flash
hl("FlashMatch", { fg = "#7481B9", bg = "#282a3a" })
hl("FlashCurrent", { fg = "#7481B9", bg = "#282a3a" })

-- Mason
hl("MasonHighlight", { fg = "#6789d0" })
hl("MasonHighlightBlockBold", { fg = "#1F2029", bg = "#6789d0" })
hl("MasonMuted", { fg = "#4d5579" })
hl("MasonMutedBlock", { bg = "" })

-- Mini.clue
hl("MiniClueBorder", { link = "WinSeparator" })
hl("MiniClueDescGroup", { fg = "#6789d0" })
hl("MiniClueDescSingle", { link = "Normal" })
hl("MiniClueNextKey", { link = "Normal" })
hl("MiniClueNextKeyWithPostkeys", { fg = "#6789d0" })
hl("MiniClueSeparator", { link = "WinSeparator" })
hl("MiniClueTitle", { fg = "#6789d0" })

-- Grug-far
hl("GrugFarResultsLineColumn", { link = "LineNr" })
hl("GrugFarResultsLineNo", { link = "LineNr" })
hl("GrugFarResultsMatch", { fg = "#1F2029", bg = "#907149" })
hl("GrugFarResultsPath", { fg = "#6789d0" })

-- MultiCursor
hl("MultiCursorCursor", { link = "Cursor" })
hl("MultiCursorVisual", { link = "Visual" })
hl("MultiCursorDisabledCursor", { link = "Visual" })
hl("MultiCursorDisabledVisual", { link = "Visual" })

-- NvimTree
hl("NvimTreeBookmarkIcon", { fg = "#6789d0" })
hl("NvimTreeEmptyFolderName", { fg = "#6974a6" })
hl("NvimTreeFileIcon", { fg = "#6974a6" })
hl("NvimTreeFolderIcon", { fg = "#6974a6" })
hl("NvimTreeFolderName", { fg = "#6974a6" })
hl("NvimTreeGitDeletedIcon", { fg = "#9e4f5f" })
hl("NvimTreeGitDirtyIcon", { fg = "#816644" })
hl("NvimTreeGitIgnoredIcon", { fg = "#4d5579" })
hl("NvimTreeGitMergeIcon", { fg = "#b05669" })
hl("NvimTreeGitNewIcon", { fg = "#5f7a46" })
hl("NvimTreeGitRenamedIcon", { fg = "#816644" })
hl("NvimTreeGitStagedIcon", { fg = "#816644" })
hl("NvimTreeImageFile", { fg = "#6974a6" })
hl("NvimTreeNormal", { fg = "#6974a6", bg = "#1F2029" })
hl("NvimTreeOpenedFolderName", { fg = "#6974a6" })
hl("NvimTreeSpecialFile", { fg = "#6974a6" })
hl("NvimTreeWindowPicker", { fg = "#1F2029", bg = "#6789d0" })

-- Cmp
hl("CmpItemAbbrMatch", { fg = "#907149" })
hl("CmpItemAbbrMatchFuzzy", { fg = "#907149" })

-- Telescope
hl("TelescopeBorder", { fg = "#1F2029" })
hl("TelescopeMatching", { fg = "#907149" })
hl("TelescopeNormal", { fg = "#7481B9" })
hl("TelescopePromptCounter", { fg = "#6789d0" })
hl("TelescopePromptTitle", { fg = "#6789d0" })

-- GitSigns
hl("GitSignsAdd", { fg = "#546b40" })
hl("GitSignsChange", { fg = "#715a3e" })
hl("GitSignsDelete", { fg = "#8a4655" })

-- Egrepify
hl("EgrepifyCol", { link = "LineNr" })
hl("EgrepifyLnum", { link = "LineNr" })

-- RenderMarkdown
hl("RenderMarkdownH1Bg", { fg = "#6789d0", bg = "#262c3d" })
hl("RenderMarkdownH2Bg", { fg = "#6789d0", bg = "#262c3d" })
hl("RenderMarkdownH3Bg", { fg = "#6789d0", bg = "#262c3d" })
hl("RenderMarkdownH4Bg", { fg = "#6789d0", bg = "#262c3d" })
hl("RenderMarkdownH5Bg", { fg = "#6789d0", bg = "#262c3d" })
hl("RenderMarkdownH6Bg", { fg = "#6789d0", bg = "#262c3d" })
hl("RenderMarkdownBullet", { fg = "#555e86" })
hl("RenderMarkdownUnchecked", { fg = "#5c6692" })
hl("RenderMarkdownChecked", { fg = "#866fb1" })
hl("RenderMarkdownTodo", { fg = "#b05669" })
hl("RenderMarkdownQuote", { fg = "#4d5579" })
-- RenderMarkdownTableHead
-- RenderMarkdownTableRow
-- RenderMarkdownTableFill
hl("RenderMarkdownInfo", { fg = "#6789d0" })
hl("RenderMarkdownSuccess", { fg = "#69884b" })
hl("RenderMarkdownHint", { fg = "#6789d0" })
hl("RenderMarkdownWarn", { fg = "#907149" })
hl("RenderMarkdownError", { fg = "#b05669" })
hl("RenderMarkdownQuote", { fg = "#4d5579" })
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
