if vim.g.colors_name then
    vim.cmd("hi clear")
end

vim.g.colors_name = "galbadia"
vim.opt.background = "dark"

local function set_hl(name, style)
    vim.api.nvim_set_hl(0, name, style)
end

local set_js_hl = function(name, style)
    set_hl(name .. ".jsx", style)
    set_hl(name .. ".tsx", style)
    set_hl(name .. ".javascript", style)
    set_hl(name .. ".typescript", style)
    set_hl(name .. ".javascriptreact", style)
    set_hl(name .. ".typescriptreact", style)
end

set_hl("@attribute.css", { fg = "#a36747" })
set_hl("@boolean", { fg = "#a36747" })
set_hl("@character", { fg = "#69884b" })
set_hl("@character.special", { fg = "#866fb1" })
set_hl("@comment", { fg = "#555e86" })
set_hl("@comment.todo", { fg = "#b05669" })
set_hl("@constant", { fg = "#7481b9" })
set_hl("@constant.builtin", { fg = "#a36747" })
set_hl("@constant.builtin.rust", { fg = "#51909f" })
set_hl("@constant.css", { fg = "#907149" })
set_hl("@constant.elixir", { fg = "#7481b9" })
set_hl("@constructor.python", { fg = "#6789d0" })
set_hl("@function", { fg = "#6789d0" })
set_hl("@function.builtin", { fg = "#6789d0" })
set_hl("@function.macro", { fg = "#6789d0" })
set_hl("@keyword", { fg = "#866fb1" })
set_hl("@keyword.directive.markdown", { fg = "#866fb1" })
set_hl("@label.javascript", { fg = "#866fb1" })
set_hl("@label.markdown", { fg = "#7481b9" })
set_hl("@label.ruby", { fg = "#555e86" })
set_hl("@label.yaml", { fg = "#7481b9" })
set_hl("@markup.heading", { fg = "#6789d0" })
set_hl("@markup.heading.1.html", { fg = "#7481b9" })
set_hl("@markup.heading.2.html", { fg = "#7481b9" })
set_hl("@markup.heading.3.html", { fg = "#7481b9" })
set_hl("@markup.heading.4.html", { fg = "#7481b9" })
set_hl("@markup.heading.5.html", { fg = "#7481b9" })
set_hl("@markup.heading.6.html", { fg = "#7481b9" })
set_hl("@markup.heading.7.html", { fg = "#7481b9" })
set_hl("@markup.heading.html", { fg = "#7481b9" })
set_hl("@markup.italic.markdown_inline", { fg = "#866fb1", italic = true })
set_hl("@markup.link.label.markdown_inline", { fg = "#6789d0" })
set_hl("@markup.list", { fg = "#5c6692" })
set_hl("@markup.quote.markdown", { italic = true })
set_hl("@markup.raw.markdown_inline", { fg = "#866fb1" })
set_hl("@markup.strikethrough.markdown_inline", { strikethrough = true })
set_hl("@markup.strong.markdown_inline", { fg = "#866fb1", bold = true })
set_hl("@module.elixir", { fg = "#7481b9" })
set_hl("@number", { fg = "#a36747" })
set_hl("@number.css", { fg = "#a36747" })
set_hl("@number.float.css", { fg = "#a36747" })
set_hl("@operator", { fg = "#866fb1" })
set_hl("@property", { fg = "#7481b9" })
set_hl("@punctuation", { fg = "#5c6692" })
set_hl("@punctuation.delimiter.regex", { fg = "#866fb1" })
set_hl("@punctuation.special", { fg = "#866fb1" })
set_hl("@punctuation.special.markdown", { fg = "#5c6692" })
set_hl("@string", { fg = "#69884b" })
set_hl("@string.css", { fg = "#69884b" })
set_hl("@string.documentation", { fg = "#555e86" })
set_hl("@string.escape", { fg = "#866fb1" })
set_hl("@string.special", { fg = "#866fb1" })
set_hl("@string.special.symbol", { fg = "#7481b9" })
set_hl("@string.special.symbol.elixir", { fg = "#7481b9" })
set_hl("@tag.attribute", { fg = "#907149" })
set_hl("@tag.builtin", { fg = "#866fb1" })
set_hl("@tag.css", { fg = "#866fb1" })
set_hl("@tag.delimiter", { fg = "#5c6692" })
set_hl("@tag.html", { fg = "#866fb1" })
set_hl("@type", { fg = "#7481b9" })
set_hl("@type.builtin", { fg = "#51909f" })
set_hl("@type.css", { fg = "#907149" })
set_hl("@type.definition.go", { fg = "#7481b9" })
set_hl("@type.prisma", { fg = "#866fb1" })
set_hl("@variable", { fg = "#7481b9" })
set_hl("@variable.builtin", { fg = "#866fb1" })
set_hl("@variable.parameter", { fg = "#907149" })
set_hl("Character", { link = "String" })
set_hl("CmpItemAbbrMatch", { fg = "#6789d0" })
set_hl("CmpItemAbbrMatchFuzzy", { fg = "#6789d0" })
set_hl("Comment", { fg = "#555e86" })
set_hl("Conceal", { fg = "#555e86" })
set_hl("Constant", { fg = "#a36747" })
set_hl("CurSearch", { bg = "#303346" })
set_hl("CursorLine", { bg = "#282a37" })
set_hl("CursorLineNr", { fg = "#636e9c" })
set_hl("Delimiter", { fg = "#5c6692" })
set_hl("DiagnosticError", { fg = "#b05669" })
set_hl("DiagnosticHint", { fg = "#6789d0" })
set_hl("DiagnosticInfo", { fg = "#6789d0" })
set_hl("DiagnosticOk", { fg = "#69884b" })
set_hl("DiagnosticUnderlineError", { fg = "#b05669" })
set_hl("DiagnosticUnderlineWarn", { fg = "#907149" })
set_hl("DiagnosticUnnecessary", { fg = "#5a648e" })
set_hl("DiagnosticVirtualTextError", { fg = "#b05669" })
set_hl("DiagnosticVirtualTextHint", { fg = "#6789d0" })
set_hl("DiagnosticVirtualTextInfo", { fg = "#6789d0" })
set_hl("DiagnosticVirtualTextWarn", { fg = "#907149" })
set_hl("DiagnosticWarn", { fg = "#907149" })
set_hl("Directory", { fg = "#6789d0" })
set_hl("EgrepifyCol", { fg = "#555e86" })
set_hl("EgrepifyLnum", { fg = "#555e86" })
set_hl("Error", { fg = "#b05669" })
set_hl("ErrorMsg", { fg = "#b05669" })
set_hl("FloatBorder", { fg = "#181921", bg = "#1f2029" })
set_hl("FloatTitle", { fg = "#6789d0", bg = "#1f2029" })
set_hl("Function", { fg = "#6789d0" })
set_hl("GitSignsAdd", { fg = "#69884b" })
set_hl("GitSignsChange", { fg = "#907149" })
set_hl("GitSignsDelete", { fg = "#b05669" })
set_hl("healthError", { fg = "#b05669" })
set_hl("healthSuccess", { fg = "#69884b" })
set_hl("healthWarning", { fg = "#907149" })
set_hl("HydraAmaranth", { fg = "#a36747" })
set_hl("HydraBlue", { fg = "#6789d0" })
set_hl("HydraPink", { fg = "#866fb1" })
set_hl("HydraRed", { fg = "#b05669" })
set_hl("HydraTeal", { fg = "#51909f" })
set_hl("Identifier", { fg = "#7481b9" })
set_hl("IncSearch", { bg = "#303346" })
set_hl("Keyword", { fg = "#866fb1" })
set_hl("LineNr", { fg = "#525a7f" })
set_hl("LspSignatureActiveParameter", { fg = "#907149", bg = "#282a37" })
set_hl("MasonHighlight", { fg = "#6789d0" })
set_hl("MasonHighlightBlockBold", { fg = "#1f2029", bg = "#6789d0" })
set_hl("MasonMuted", { fg = "#56586c" })
set_hl("MasonMutedBlock", { bg = "#282a37" })
set_hl("MatchParen", { fg = "NONE" })
set_hl("MiniClueBorder", { fg = "#181921", bg = "#1f2029" })
set_hl("MiniClueDescGroup", { fg = "#907149", bg = "#1f2029" })
set_hl("MiniClueDescSingle", { fg = "#7481b9", bg = "#1f2029" })
set_hl("MiniClueNextKey", { fg = "#7481b9", bg = "#1f2029" })
set_hl("MiniClueNextKeyWithPostkeys", { fg = "#907149", bg = "#1f2029" })
set_hl("MiniClueSeparator", { fg = "#181921", bg = "#1f2029" })
set_hl("MiniClueTitle", { fg = "#6789d0", bg = "#1f2029" })
set_hl("ModeMsg", { fg = "#7481b9" })
set_hl("MoreMsg", { fg = "#6789d0" })
set_hl("MsgArea", { fg = "#7b7e99", bg = "#1f2029" })
set_hl("MultiCursor", { link = "Visual" })
set_hl("MultiCursorMain", { link = "Visual" })
set_hl("Normal", { fg = "#7481b9", bg = "#1f2029" })
set_hl("NormalFloat", { fg = "#7481b9", bg = "#1f2029" })
set_hl("NormalTerm", { fg = "#7b7e99", bg = "#1f2029" })
set_hl("NvimTreeBookmarkIcon", { fg = "#6789d0" })
set_hl("NvimTreeEmptyFolderName", { fg = "#7b7e99" })
set_hl("NvimTreeFileIcon", { fg = "#7b7e99" })
set_hl("NvimTreeFolderIcon", { fg = "#7b7e99" })
set_hl("NvimTreeFolderName", { fg = "#7b7e99" })
set_hl("NvimTreeGitDeletedIcon", { fg = "#9d576b" })
set_hl("NvimTreeGitDirtyIcon", { fg = "#826b56" })
set_hl("NvimTreeGitIgnoredIcon", { fg = "#56586c" })
set_hl("NvimTreeGitMergeIcon", { fg = "#b05669" })
set_hl("NvimTreeGitNewIcon", { fg = "#647d57" })
set_hl("NvimTreeGitRenamedIcon", { fg = "#826b56" })
set_hl("NvimTreeGitStagedIcon", { fg = "#826b56" })
set_hl("NvimTreeImageFile", { fg = "#7b7e99" })
set_hl("NvimTreeNormal", { fg = "#7b7e99", bg = "#1f2029" })
set_hl("NvimTreeOpenedFolderName", { fg = "#7b7e99" })
set_hl("NvimTreeRootFolder", { fg = "#6789d0" })
set_hl("NvimTreeSpecialFile", { fg = "#7b7e99" })
set_hl("NvimTreeStatusLine", { fg = "#7b7e99", bg = "#1f2029", ctermfg = "white" })
set_hl("NvimTreeStatusLineNC", { fg = "#7b7e99", bg = "#1f2029", ctermfg = "black" })
set_hl("NvimTreeWindowPicker", { fg = "#1f2029", bg = "#6789d0" })
set_hl("NvimTreeWinSeparator", { fg = "#181921", bg = "#1f2029" })
set_hl("Operator", { link = "Keyword" })
set_hl("Pmenu", { fg = "#7b7e99", bg = "#1f2029" })
set_hl("PmenuSbar", { bg = "#282934" })
set_hl("PmenuSel", { bg = "#31333f" })
set_hl("PmenuThumb", { bg = "#31333f" })
set_hl("PreProc", { fg = "#6789d0" })
set_hl("Question", { fg = "#6789d0" })
set_hl("Search", { bg = "#282a37" })
set_hl("SignColumn", { fg = "#7481b9", bg = "#1f2029" })
set_hl("Special", { fg = "#866fb1" })
set_hl("Statement", { fg = "#866fb1" })
set_hl("Statement", { link = "Keyword" })
set_hl("StatusLine", { fg = "#7b7e99", bg = "#1f2029", ctermfg = "white" })
set_hl("StatusLineNC", { fg = "#7b7e99", bg = "#1f2029", ctermfg = "black" })
set_hl("String", { fg = "#69884b" })
set_hl("Substitute", { fg = "#1f2029", bg = "#907149" })
set_hl("Tabline", { fg = "#7481b9", bg = "#1f2029" })
set_hl("TablineFill", { fg = "#1f2029", bg = "#1f2029" })
set_hl("TablineSel", { fg = "#6789d0", bg = "#1f2029" })
set_hl("TelescopeBorder", { fg = "#1f2029", bg = "#1f2029" })
set_hl("TelescopeMatching", { fg = "#907149" })
set_hl("TelescopeNormal", { fg = "#7b7e99", bg = "#1f2029" })
set_hl("TelescopePromptCounter", { fg = "#6789d0" })
set_hl("TelescopePromptTitle", { fg = "#6789d0", bg = "#1f2029" })
set_hl("Title", { fg = "#6789d0" })
set_hl("Type", { fg = "#51909f" })
set_hl("VertSplit", { fg = "#181921" })
set_hl("Visual", { bg = "#303346" })
set_hl("WarningMsg", { fg = "#907149" })
set_hl("WinBar", { fg = "#7481b9", bg = "#1f2029" })
set_hl("WinBarNC", { fg = "#7481b9", bg = "#1f2029" })
set_hl("WinSeparator", { fg = "#181921" })
set_js_hl("@constructor", { fg = "#6789d0" })
set_js_hl("@tag", { fg = "#6789d0" })

vim.g.terminal_color_0 = "#3e3f4e"
vim.g.terminal_color_1 = "#b05669"
vim.g.terminal_color_2 = "#69884b"
vim.g.terminal_color_3 = "#907149"
vim.g.terminal_color_4 = "#6789d0"
vim.g.terminal_color_5 = "#866fb1"
vim.g.terminal_color_6 = "#51909f"
vim.g.terminal_color_7 = "#515366"

vim.g.terminal_color_8 = "#3e3f4e"
vim.g.terminal_color_9 = "#b05669"
vim.g.terminal_color_10 = "#69884b"
vim.g.terminal_color_11 = "#907149"
vim.g.terminal_color_12 = "#6789d0"
vim.g.terminal_color_13 = "#866fb1"
vim.g.terminal_color_14 = "#51909f"
vim.g.terminal_color_15 = "#515366"