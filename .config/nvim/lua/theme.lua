local bg = "#1F2029"
local fg = "#7481B9"
local border = "#181921"
local blue = "#6789d0"
local green = "#69884b"
local magenta = "#866fb1"
local orange = "#a36747"
local purple = "#9D7CD8"
local red = "#b05669"
local cyan = "#51909f"
local yellow = "#907149"
local fg_50 = "#282a3a"
local fg_100 = "#2f3346"
local fg_200 = "#3b405a"
local fg_300 = "#454c6b"
local fg_400 = "#4d5579"
local fg_500 = "#555e86"
local fg_600 = "#5c6692"
local fg_700 = "#636d9c"
local fg_800 = "#6974a6"
local fg_900 = "#6e7bb0"
local blue_50 = "#262c3d"
local blue_100 = "#2c354c"
local blue_200 = "#364464"
local blue_300 = "#3e5077"
local blue_400 = "#455a87"
local blue_500 = "#4c6396"
local blue_600 = "#526ca3"
local blue_700 = "#5874af"
local blue_800 = "#5d7bbb"
local blue_900 = "#6282c6"
local green_50 = "#262c2b"
local green_100 = "#2c352e"
local green_200 = "#374332"
local green_300 = "#3f4f36"
local green_400 = "#475a39"
local green_500 = "#4d633c"
local green_600 = "#546b40"
local green_700 = "#597343"
local green_800 = "#5f7a46"
local green_900 = "#648148"
local magenta_50 = "#2b2838"
local magenta_100 = "#342e44"
local magenta_200 = "#423957"
local magenta_300 = "#4e4267"
local magenta_400 = "#584a74"
local magenta_500 = "#615280"
local magenta_600 = "#6a588c"
local magenta_700 = "#715f96"
local magenta_800 = "#79649f"
local magenta_900 = "#806aa8"
local orange_50 = "#2f272b"
local orange_100 = "#3b2d2d"
local orange_200 = "#4e3631"
local orange_300 = "#5d3e34"
local orange_400 = "#6a4637"
local orange_500 = "#754c3a"
local orange_600 = "#80523d"
local orange_700 = "#895840"
local orange_800 = "#925d42"
local orange_900 = "#9b6245"
local purple_50 = "#2e2a3f"
local purple_100 = "#3a324f"
local purple_200 = "#4b3e67"
local purple_300 = "#5a497b"
local purple_400 = "#66528c"
local purple_500 = "#715b9b"
local purple_600 = "#7b62a9"
local purple_700 = "#8469b6"
local purple_800 = "#8d70c2"
local purple_900 = "#9576cd"
local red_50 = "#32252e"
local red_100 = "#3f2933"
local red_200 = "#53303c"
local red_300 = "#643643"
local red_400 = "#723c4a"
local red_500 = "#7e4150"
local red_600 = "#8a4655"
local red_700 = "#944a5b"
local red_800 = "#9e4e60"
local red_900 = "#a75264"
local cyan_50 = "#232d35"
local cyan_100 = "#273740"
local cyan_200 = "#2e4650"
local cyan_300 = "#33535e"
local cyan_400 = "#395e69"
local cyan_500 = "#3d6874"
local cyan_600 = "#42717e"
local cyan_700 = "#467a87"
local cyan_800 = "#4a828f"
local cyan_900 = "#4d8997"
local yellow_50 = "#2c282b"
local yellow_100 = "#362f2d"
local yellow_200 = "#463a31"
local yellow_300 = "#534335"
local yellow_400 = "#5e4c38"
local yellow_500 = "#68533b"
local yellow_600 = "#715a3e"
local yellow_700 = "#7a6041"
local yellow_800 = "#826644"
local yellow_900 = "#896c46"

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
hl("Comment", { fg = fg_400 })
hl("Conceal", { link = "Comment" })
hl("Constant", { fg = orange })
hl("CurSearch", { link = "Visual" })
hl("Delimiter", { fg = fg_500 })
hl("DiagnosticError", { fg = red })
hl("DiagnosticHint", { fg = blue })
hl("DiagnosticInfo", { fg = blue })
hl("DiagnosticOk", { fg = green })
hl("DiagnosticUnderlineError", { fg = red })
hl("DiagnosticUnderlineWarn", { fg = yellow })
hl("DiagnosticUnnecessary", { fg = fg_600 })
hl("DiagnosticWarn", { fg = yellow })
hl("Directory", { fg = blue })
hl("Error", { fg = red })
hl("ErrorMsg", { fg = red })
hl("FloatBorder", { link = "WinSeparator" })
hl("FloatTitle", { fg = blue })
hl("Folded", { link = "Comment" })
hl("Function", { fg = blue })
hl("healthError", { fg = red })
hl("healthSuccess", { fg = green })
hl("healthWarning", { fg = yellow })
hl("Identifier", { fg = fg })
hl("IncSearch", { fg = bg, background = yellow })
hl("Keyword", { fg = magenta })
hl("LineNr", { fg = fg_500 })
hl("CursorLine", { bg = fg_50 })
hl("MatchParen", { fg = "NONE" })
hl("ModeMsg", { fg = fg_700, bg = bg })
hl("MoreMsg", { fg = blue })
hl("MsgArea", { link = "StatusLine" })
hl("Normal", { fg = fg, bg = bg })
hl("NormalFloat", { link = "Normal" })
hl("NormalTerm", { fg = fg_800, bg = bg })
hl("Operator", { link = "Keyword" })
hl("Pmenu", { fg = fg_800, bg = bg })
hl("PmenuSel", { fg = fg, bg = fg_100 })
hl("PmenuThumb", { bg = fg_50 })
hl("PreProc", { fg = blue })
hl("Question", { fg = blue })
hl("SignColumn", { link = "Normal" })
hl("Special", { link = "Keyword" })
hl("SpellBad", { link = "DiagnosticUnderlineWarn" })
hl("Statement", { link = "Keyword" })
hl("StatusLine", { fg = fg_700, bg = bg, ctermfg = "white" })
hl("StatusLineNC", { link = "StatusLine", ctermfg = "black" })
hl("String", { fg = green })
hl("Substitute", { fg = bg, background = yellow })
hl("Title", { fg = "" })
hl("Type", { fg = cyan })
hl("VertSplit", { link = "WinSeparator" })
hl("Visual", { bg = fg_100 })
hl("WarningMsg", { fg = yellow })
hl("WinBar", { link = "Normal" })
hl("WinBarNC", { link = "WinBar" })
hl("WinSeparator", { fg = border })
hl("DiffDelete", { fg = red, bg = red_50 })
hl("DiffAdd", { fg = green, bg = green_50 })

-- Terminal
vim.g.terminal_color_0 = fg_300
vim.g.terminal_color_1 = red
vim.g.terminal_color_2 = green
vim.g.terminal_color_3 = yellow
vim.g.terminal_color_4 = blue
vim.g.terminal_color_5 = magenta
vim.g.terminal_color_6 = cyan
vim.g.terminal_color_7 = fg_500

vim.g.terminal_color_8 = fg_300
vim.g.terminal_color_9 = red
vim.g.terminal_color_10 = green
vim.g.terminal_color_11 = yellow
vim.g.terminal_color_12 = blue
vim.g.terminal_color_13 = magenta
vim.g.terminal_color_14 = cyan
vim.g.terminal_color_15 = fg_500

-- Treesitter
hl("@attribute.css", { link = "Constant" })
hl("@boolean", { link = "Constant" })
hl("@character", { link = "String" })
hl("@character.special", { link = "Keyword" })
hl("@comment", { link = "Comment" })
hl("@comment.todo", { fg = red, bg = red_100 })
hl("@comment.note", { fg = blue, bg = blue_100 })
hl("@constant", { fg = fg })
hl("@constant.builtin", { link = "Constant" })
hl("@constant.builtin.rust", { link = "Type" })
hl("@constant.css", { fg = orange })
hl("@constant.elixir", { fg = fg })
hl("@constructor.python", { link = "Function" })
hl("@function", { link = "Function" })
hl("@function.builtin", { link = "Function" })
hl("@function.macro", { link = "Function" })
hl("@keyword", { link = "Keyword" })
hl("@keyword.directive.markdown", { link = "Keyword" })
hl("@label.javascript", { link = "Keyword" })
hl("@label.markdown", { fg = fg })
hl("@label.ruby", { link = "Comment" })
hl("@label.yaml", { fg = fg })
hl("@markup.heading", { fg = blue })
hl("@markup.heading.1.html", { fg = fg })
hl("@markup.heading.2.html", { fg = fg })
hl("@markup.heading.3.html", { fg = fg })
hl("@markup.heading.4.html", { fg = fg })
hl("@markup.heading.5.html", { fg = fg })
hl("@markup.heading.6.html", { fg = fg })
hl("@markup.heading.7.html", { fg = fg })
hl("@markup.heading.html", { fg = fg })
hl("@markup.italic.markdown_inline", { fg = blue, italic = true })
hl("@markup.link.label.markdown_inline", { fg = blue })
hl("@markup.list", { link = "Delimiter" })
hl("@markup.quote.markdown", { italic = true })
hl("@markup.raw.markdown_inline", { fg = magenta })
hl("@markup.strikethrough.markdown_inline", { strikethrough = true })
hl("@markup.strong.markdown_inline", { fg = blue, bold = true })
hl("@module.elixir", { fg = fg })
hl("@number", { link = "Constant" })
hl("@number.css", { link = "Constant" })
hl("@number.float.css", { link = "Constant" })
hl("@operator", { link = "Keyword" })
hl("@property", { fg = fg })
hl("@punctuation", { link = "Delimiter" })
hl("@punctuation.delimiter.regex", { link = "Keyword" })
hl("@punctuation.special", { link = "Keyword" })
hl("@punctuation.special.markdown", { link = "Delimiter" })
hl("@string", { link = "String" })
hl("@string.css", { link = "String" })
hl("@string.documentation", { link = "Comment" })
hl("@string.escape", { link = "Keyword" })
hl("@string.special", { link = "Keyword" })
hl("@string.special.symbol", { fg = fg })
hl("@string.special.symbol.elixir", { fg = fg })
hl("@tag.attribute", { fg = yellow })
hl("@tag.builtin", { link = "Keyword" })
hl("@tag.css", { link = "Keyword" })
hl("@tag.delimiter", { link = "Delimiter" })
hl("@tag.html", { link = "Keyword" })
hl("@type", { fg = fg })
hl("@type.builtin", { link = "Type" })
hl("@type.css", { fg = yellow })
hl("@type.definition.go", { fg = fg })
hl("@type.prisma", { link = "Keyword" })
hl("@variable", { fg = fg })
hl("@variable.builtin", { link = "Keyword" })
hl("@variable.parameter", { fg = yellow })
js("@constructor", { link = "Function" })
js("@tag", { link = "Function" })

-- Flash
hl("FlashMatch", { fg = fg, bg = fg_50 })
hl("FlashCurrent", { fg = fg, bg = fg_50 })

-- Mason
hl("MasonError", { fg = red })
hl("MasonHeader", { fg = fg })
hl("MasonHeaderSecondary", { fg = fg })
hl("MasonHeading", { fg = blue, bg = blue_100 })
hl("MasonHighlight", { fg = blue })
hl("MasonHighlightBlock", { fg = bg, bg = blue })
hl("MasonHighlightBlockBold", { fg = bg, bg = blue })
hl("MasonMuted", { fg = fg_400 })
hl("MasonMutedBlock", { bg = fg_50 })
hl("MasonWarning", { fg = yellow })

-- Mini.clue
hl("MiniClueBorder", { link = "WinSeparator" })
hl("MiniClueDescGroup", { fg = blue })
hl("MiniClueDescSingle", { link = "Normal" })
hl("MiniClueNextKey", { link = "Normal" })
hl("MiniClueNextKeyWithPostkeys", { fg = blue })
hl("MiniClueSeparator", { link = "WinSeparator" })
hl("MiniClueTitle", { fg = blue })

-- Grug-far
hl("GrugFarResultsMatch", { fg = bg, bg = yellow })
hl("GrugFarResultsPath", { fg = blue })
hl("GrugFarHelpHeader", { fg = fg })
hl("GrugFarHelpHeaderKey", { fg = magenta })
hl("GrugFarHelpWinHeader", { fg = blue })
hl("GrugFarHelpWinActionPrefix", { fg = fg_500 })
hl("GrugFarHelpWinActionText", { fg = fg })
hl("GrugFarHelpWinActionKey", { fg = magenta })
hl("GrugFarHelpWinActionDescription", { fg = fg_800 })
hl("GrugFarInputLabel", { fg = blue })

-- MultiCursor
hl("MultiCursorCursor", { link = "Cursor" })
hl("MultiCursorVisual", { link = "Visual" })
hl("MultiCursorDisabledCursor", { link = "Visual" })
hl("MultiCursorDisabledVisual", { link = "Visual" })

-- NvimTree
hl("NvimTreeBookmarkIcon", { fg = blue })
hl("NvimTreeEmptyFolderName", { fg = fg_800 })
hl("NvimTreeFileIcon", { fg = fg_800 })
hl("NvimTreeFolderIcon", { fg = fg_800 })
hl("NvimTreeFolderName", { fg = fg_800 })
hl("NvimTreeGitDeletedIcon", { fg = red_800 })
hl("NvimTreeGitDirtyIcon", { fg = yellow_800 })
hl("NvimTreeGitIgnoredIcon", { fg = fg_400 })
hl("NvimTreeGitMergeIcon", { fg = red })
hl("NvimTreeGitNewIcon", { fg = green_800 })
hl("NvimTreeGitRenamedIcon", { fg = yellow_800 })
hl("NvimTreeGitStagedIcon", { fg = fg_800 })
hl("NvimTreeImageFile", { fg = fg_800 })
hl("NvimTreeNormal", { fg = fg_800, bg = bg })
hl("NvimTreeOpenedFolderName", { fg = fg_800 })
hl("NvimTreeSpecialFile", { fg = fg_800 })
hl("NvimTreeWindowPicker", { fg = bg, bg = blue })

-- Blink
-- TODO
hl("BlinkCmpMenuBorder", { link = "WinSeparator" })
hl("BlinkCmpDocBorder", { link = "WinSeparator" })
hl("PmenuExtra", { fg = blue })
-- hl("BlinkCmpLabelDescription", { fg = blue })
-- hl("BlinkCmpLabelDeprecated", { link = "Comment" })
hl("BlinkCmpKind", { link = "NONE" })

-- Telescope
hl("TelescopeBorder", { fg = bg })
hl("TelescopeMatching", { fg = yellow })
hl("TelescopeNormal", { fg = fg })
hl("TelescopePromptCounter", { fg = blue })
hl("TelescopePromptTitle", { fg = blue })

-- Mini.signs
hl("MiniDiffSignAdd", { fg = green_600 })
hl("MiniDiffSignChange", { fg = yellow_600 })
hl("MiniDiffSignDelete", { fg = red_600 })

-- Egrepify
hl("EgrepifyCol", { link = "LineNr" })
hl("EgrepifyLnum", { link = "LineNr" })

-- RenderMarkdown
hl("RenderMarkdownH1Bg", { fg = blue, bg = blue_50 })
hl("RenderMarkdownH2Bg", { fg = blue, bg = blue_50 })
hl("RenderMarkdownH3Bg", { fg = blue, bg = blue_50 })
hl("RenderMarkdownH4Bg", { fg = blue, bg = blue_50 })
hl("RenderMarkdownH5Bg", { fg = blue, bg = blue_50 })
hl("RenderMarkdownH6Bg", { fg = blue, bg = blue_50 })
hl("RenderMarkdownBullet", { fg = fg_500 })
hl("RenderMarkdownUnchecked", { fg = fg_600 })
hl("RenderMarkdownChecked", { fg = magenta })
hl("RenderMarkdownTodo", { fg = red })
hl("RenderMarkdownQuote", { fg = fg_400 })
hl("RenderMarkdownTableHead", { link = "Delimiter" })
hl("RenderMarkdownTableRow", { link = "Delimiter" })
hl("RenderMarkdownTableFill", { link = "Delimiter" })
hl("RenderMarkdownInfo", { fg = blue })
hl("RenderMarkdownSuccess", { fg = green })
hl("RenderMarkdownHint", { fg = blue })
hl("RenderMarkdownWarn", { fg = yellow })
hl("RenderMarkdownError", { fg = red })
hl("RenderMarkdownQuote", { fg = fg_400 })

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
