if vim.g.colors_name then
    vim.cmd("hi clear")
end

vim.g.colors_name = "{{name}}"
vim.opt.background = "{{mode}}"

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
hl("Comment", { fg = "{{syntax.comment}}" })
hl("Conceal", { link = "Comment" })
hl("Constant", { fg = "{{syntax.constant}}" })
hl("CurSearch", { link = "Visual" })
hl("CursorLine", { bg = "{{editor.highlight}}" })
hl("Delimiter", { fg = "{{syntax.punctuation}}" })
hl("DiagnosticError", { fg = "{{error}}" })
hl("DiagnosticHint", { fg = "{{info}}" })
hl("DiagnosticInfo", { fg = "{{info}}" })
hl("DiagnosticOk", { fg = "{{success}}" })
hl("DiagnosticUnderlineError", { fg = "{{error}}" })
hl("DiagnosticUnderlineWarn", { fg = "{{warning}}" })
hl("DiagnosticUnnecessary", { fg = "{{syntax.unused}}" })
hl("DiagnosticWarn", { fg = "{{warning}}" })
hl("Directory", { fg = "{{accent}}" })
hl("Error", { fg = "{{error}}" })
hl("ErrorMsg", { fg = "{{error}}" })
hl("FloatBorder", { link = "WinSeparator" })
hl("FloatTitle", { fg = "{{accent}}" })
hl("Folded", { link = "Comment" })
hl("Function", { fg = "{{syntax.function}}" })
hl("healthError", { fg = "{{error}}" })
hl("healthSuccess", { fg = "{{success}}" })
hl("healthWarning", { fg = "{{warning}}" })
hl("Identifier", { fg = "{{editor.foreground}}" })
hl("IncSearch", { fg = "{{editor.background}}", background = "{{search}}" })
hl("Keyword", { fg = "{{syntax.keyword}}" })
hl("LineNr", { fg = "{{editor.linenr}}" })
hl("MatchParen", { fg = "NONE" })
hl("ModeMsg", { fg = "{{msgarea.foreground}}", bg = "{{msgarea.background}}" })
hl("MoreMsg", { fg = "{{accent}}" })
hl("MsgArea", { link = "StatusLine" })
hl("Normal", { fg = "{{editor.foreground}}", bg = "{{editor.background}}" })
hl("NormalFloat", { link = "Normal" })
hl("NormalTerm", { fg = "{{terminal.foreground}}", bg = "{{terminal.background}}" })
hl("Operator", { link = "Keyword" })
hl("Pmenu", { fg = "{{pmenu.foreground}}", bg = "{{pmenu.background}}" })
hl("PmenuSel", { bg = "{{pmenu.selection}}" })
hl("PmenuThumb", { bg = "{{pmenu.thumb}}" })
hl("PreProc", { fg = "{{accent}}" })
hl("Question", { fg = "{{accent}}" })
hl("SignColumn", { link = "Normal" })
hl("Special", { link = "Keyword" })
hl("SpellBad", { link = "DiagnosticUnderlineWarn" })
hl("Statement", { link = "Keyword" })
hl("StatusLine", { fg = "{{statusline.foreground}}", bg = "{{statusline.background}}", ctermfg = "white" })
hl("StatusLineNC", { link = "StatusLine", ctermfg = "black" })
hl("String", { fg = "{{syntax.string}}" })
hl("Substitute", { fg = "{{editor.background}}", background = "{{search}}" })
hl("Title", { fg = "{{title}}" })
hl("Type", { fg = "{{syntax.type}}" })
hl("VertSplit", { link = "WinSeparator" })
hl("Visual", { bg = "{{editor.selection}}" })
hl("WarningMsg", { fg = "{{warning}}" })
hl("WinBar", { fg = "{{winbar.foreground}}", bg = "{{winbar.background}}" })
hl("WinBarNC", { link = "WinBar" })
hl("WinSeparator", { fg = "{{border}}" })

-- Terminal
vim.g.terminal_color_0 = "{{terminal.black}}"
vim.g.terminal_color_1 = "{{terminal.red}}"
vim.g.terminal_color_2 = "{{terminal.green}}"
vim.g.terminal_color_3 = "{{terminal.yellow}}"
vim.g.terminal_color_4 = "{{terminal.blue}}"
vim.g.terminal_color_5 = "{{terminal.magenta}}"
vim.g.terminal_color_6 = "{{terminal.cyan}}"
vim.g.terminal_color_7 = "{{terminal.white}}"

vim.g.terminal_color_8 = "{{terminal.black}}"
vim.g.terminal_color_9 = "{{terminal.red}}"
vim.g.terminal_color_10 = "{{terminal.green}}"
vim.g.terminal_color_11 = "{{terminal.yellow}}"
vim.g.terminal_color_12 = "{{terminal.blue}}"
vim.g.terminal_color_13 = "{{terminal.magenta}}"
vim.g.terminal_color_14 = "{{terminal.cyan}}"
vim.g.terminal_color_15 = "{{terminal.white}}"

-- Treesitter
hl("@attribute.css", { link = "Constant" })
hl("@boolean", { link = "Constant" })
hl("@character", { link = "String" })
hl("@character.special", { link = "Keyword" })
hl("@comment", { link = "Comment" })
hl("@comment.todo", { fg = "{{syntax.TODO.foreground}}", bg = "{{syntax.TODO.background}}" })
hl("@comment.note", { fg = "{{syntax.NOTE.foreground}}", bg = "{{syntax.NOTE.background}}" })
hl("@constant", { fg = "{{editor.foreground}}" })
hl("@constant.builtin", { link = "Constant" })
hl("@constant.builtin.rust", { link = "Type" })
hl("@constant.css", { fg = "{{syntax.constant}}" })
hl("@constant.elixir", { fg = "{{editor.foreground}}" })
hl("@constructor.python", { link = "Function" })
hl("@function", { link = "Function" })
hl("@function.builtin", { link = "Function" })
hl("@function.macro", { link = "Function" })
hl("@keyword", { link = "Keyword" })
hl("@keyword.directive.markdown", { link = "Keyword" })
hl("@label.javascript", { link = "Keyword" })
hl("@label.markdown", { fg = "{{editor.foreground}}" })
hl("@label.ruby", { link = "Comment" })
hl("@label.yaml", { fg = "{{editor.foreground}}" })
hl("@markup.heading", { fg = "{{accent}}" })
hl("@markup.heading.1.html", { fg = "{{editor.foreground}}" })
hl("@markup.heading.2.html", { fg = "{{editor.foreground}}" })
hl("@markup.heading.3.html", { fg = "{{editor.foreground}}" })
hl("@markup.heading.4.html", { fg = "{{editor.foreground}}" })
hl("@markup.heading.5.html", { fg = "{{editor.foreground}}" })
hl("@markup.heading.6.html", { fg = "{{editor.foreground}}" })
hl("@markup.heading.7.html", { fg = "{{editor.foreground}}" })
hl("@markup.heading.html", { fg = "{{editor.foreground}}" })
hl("@markup.italic.markdown_inline", { fg = "{{syntax.keyword}}", italic = true })
hl("@markup.link.label.markdown_inline", { fg = "{{accent}}" })
hl("@markup.list", { link = "Delimiter" })
hl("@markup.quote.markdown", { italic = true })
hl("@markup.raw.markdown_inline", { link = "Keyword" })
hl("@markup.strikethrough.markdown_inline", { strikethrough = true })
hl("@markup.strong.markdown_inline", { fg = "{{syntax.keyword}}", bold = true })
hl("@module.elixir", { fg = "{{editor.foreground}}" })
hl("@number", { link = "Constant" })
hl("@number.css", { link = "Constant" })
hl("@number.float.css", { link = "Constant" })
hl("@operator", { link = "Keyword" })
hl("@property", { fg = "{{editor.foreground}}" })
hl("@punctuation", { link = "Delimiter" })
hl("@punctuation.delimiter.regex", { link = "Keyword" })
hl("@punctuation.special", { link = "Keyword" })
hl("@punctuation.special.markdown", { link = "Delimiter" })
hl("@string", { link = "String" })
hl("@string.css", { link = "String" })
hl("@string.documentation", { link = "Comment" })
hl("@string.escape", { link = "Keyword" })
hl("@string.special", { link = "Keyword" })
hl("@string.special.symbol", { fg = "{{editor.foreground}}" })
hl("@string.special.symbol.elixir", { fg = "{{editor.foreground}}" })
hl("@tag.attribute", { fg = "{{syntax.attribute}}" })
hl("@tag.builtin", { link = "Keyword" })
hl("@tag.css", { link = "Keyword" })
hl("@tag.delimiter", { link = "Delimiter" })
hl("@tag.html", { link = "Keyword" })
hl("@type", { fg = "{{editor.foreground}}" })
hl("@type.builtin", { link = "Type" })
hl("@type.css", { fg = "{{syntax.attribute}}" })
hl("@type.definition.go", { fg = "{{editor.foreground}}" })
hl("@type.prisma", { link = "Keyword" })
hl("@variable", { fg = "{{editor.foreground}}" })
hl("@variable.builtin", { link = "Keyword" })
hl("@variable.parameter", { fg = "{{syntax.parameter}}" })
js("@constructor", { link = "Function" })
js("@tag", { link = "Function" })

-- Flash
hl("FlashMatch", { fg = "{{editor.foreground}}", bg = "{{editor.highlight}}" })
hl("FlashCurrent", { fg = "{{editor.foreground}}", bg = "{{editor.highlight}}" })

-- Mason
hl("MasonHighlight", { fg = "{{accent}}" })
hl("MasonHighlightBlockBold", { fg = "{{editor.background}}", bg = "{{accent}}" })
hl("MasonMuted", { fg = "{{syntax.comment}}" })
hl("MasonMutedBlock", { bg = "{{editor.highlight}}" })

-- Mini.clue
hl("MiniClueBorder", { link = "WinSeparator" })
hl("MiniClueDescGroup", { fg = "{{accent}}" })
hl("MiniClueDescSingle", { link = "Normal" })
hl("MiniClueNextKey", { link = "Normal" })
hl("MiniClueNextKeyWithPostkeys", { fg = "{{accent}}" })
hl("MiniClueSeparator", { link = "WinSeparator" })
hl("MiniClueTitle", { fg = "{{accent}}" })

-- Grug-far
hl("GrugFarResultsLineColumn", { link = "LineNr" })
hl("GrugFarResultsLineNo", { link = "LineNr" })
hl("GrugFarResultsMatch", { fg = "{{editor.background}}", bg = "{{search}}" })
hl("GrugFarResultsPath", { fg = "{{accent}}" })

-- MultiCursor
hl("MultiCursorCursor", { link = "Cursor" })
hl("MultiCursorVisual", { link = "Visual" })
hl("MultiCursorDisabledCursor", { link = "Visual" })
hl("MultiCursorDisabledVisual", { link = "Visual" })

-- NvimTree
hl("NvimTreeBookmarkIcon", { fg = "{{accent}}" })
hl("NvimTreeEmptyFolderName", { fg = "{{sidebar.foreground}}" })
hl("NvimTreeFileIcon", { fg = "{{sidebar.foreground}}" })
hl("NvimTreeFolderIcon", { fg = "{{sidebar.foreground}}" })
hl("NvimTreeFolderName", { fg = "{{sidebar.foreground}}" })
hl("NvimTreeGitDeletedIcon", { fg = "{{sidebar.deleted}}" })
hl("NvimTreeGitDirtyIcon", { fg = "{{sidebar.changed}}" })
hl("NvimTreeGitIgnoredIcon", { fg = "{{sidebar.ignored}}" })
hl("NvimTreeGitMergeIcon", { fg = "{{sidebar.conflicted}}" })
hl("NvimTreeGitNewIcon", { fg = "{{sidebar.added}}" })
hl("NvimTreeGitRenamedIcon", { fg = "{{sidebar.changed}}" })
hl("NvimTreeGitStagedIcon", { fg = "{{sidebar.foreground}}" })
hl("NvimTreeImageFile", { fg = "{{sidebar.foreground}}" })
hl("NvimTreeNormal", { fg = "{{sidebar.foreground}}", bg = "{{sidebar.background}}" })
hl("NvimTreeOpenedFolderName", { fg = "{{sidebar.foreground}}" })
hl("NvimTreeSpecialFile", { fg = "{{sidebar.foreground}}" })
hl("NvimTreeWindowPicker", { fg = "{{editor.background}}", bg = "{{accent}}" })

-- Cmp
hl("CmpFloatBorder", { fg = "{{border}}", bg = "{{pmenu.background}}" })
hl("CmpItemAbbrMatch", { fg = "{{search}}" })
hl("CmpItemAbbrMatchFuzzy", { fg = "{{search}}" })

-- Telescope
hl("TelescopeBorder", { fg = "{{editor.background}}" })
hl("TelescopeMatching", { fg = "{{search}}" })
hl("TelescopeNormal", { fg = "{{editor.foreground}}" })
hl("TelescopePromptCounter", { fg = "{{accent}}" })
hl("TelescopePromptTitle", { fg = "{{accent}}" })

-- Mini.signs
hl("MiniDiffSignAdd", { fg = "{{gutter.added}}" })
hl("MiniDiffSignChange", { fg = "{{gutter.changed}}" })
hl("MiniDiffSignDelete", { fg = "{{gutter.deleted}}" })

-- Egrepify
hl("EgrepifyCol", { link = "LineNr" })
hl("EgrepifyLnum", { link = "LineNr" })

-- RenderMarkdown
hl("RenderMarkdownH1Bg", { fg = "{{markdown.h1.foreground}}", bg = "{{markdown.h1.background}}" })
hl("RenderMarkdownH2Bg", { fg = "{{markdown.h2.foreground}}", bg = "{{markdown.h2.background}}" })
hl("RenderMarkdownH3Bg", { fg = "{{markdown.h3.foreground}}", bg = "{{markdown.h3.background}}" })
hl("RenderMarkdownH4Bg", { fg = "{{markdown.h4.foreground}}", bg = "{{markdown.h4.background}}" })
hl("RenderMarkdownH5Bg", { fg = "{{markdown.h5.foreground}}", bg = "{{markdown.h5.background}}" })
hl("RenderMarkdownH6Bg", { fg = "{{markdown.h6.foreground}}", bg = "{{markdown.h6.background}}" })
hl("RenderMarkdownBullet", { fg = "{{markdown.lists.bullet}}" })
hl("RenderMarkdownUnchecked", { fg = "{{markdown.lists.unchecked}}" })
hl("RenderMarkdownChecked", { fg = "{{markdown.lists.checked}}" })
hl("RenderMarkdownTodo", { fg = "{{markdown.lists.todo}}" })
hl("RenderMarkdownQuote", { fg = "{{markdown.quote}}" })
-- RenderMarkdownTableHead
-- RenderMarkdownTableRow
-- RenderMarkdownTableFill
hl("RenderMarkdownInfo", { fg = "{{markdown.callouts.info}}" })
hl("RenderMarkdownSuccess", { fg = "{{markdown.callouts.success}}" })
hl("RenderMarkdownHint", { fg = "{{markdown.callouts.hint}}" })
hl("RenderMarkdownWarn", { fg = "{{markdown.callouts.warn}}" })
hl("RenderMarkdownError", { fg = "{{markdown.callouts.error}}" })
hl("RenderMarkdownQuote", { fg = "{{markdown.callouts.quote}}" })
-- RenderMarkdownLink

-- WIP CodeCompanion diffs
hl("@diff.plus.diff", { fg = "{{diff.added}}" })
hl("@diff.minus.diff", { fg = "{{diff.deleted}}" })
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
