vim.cmd("highlight clear")
if vim.fn.exists("syntax_on") then
  vim.cmd("syntax reset")
end

vim.o.background  = "dark"

local palette = {
  -- Background - Made darker
  bg0     = "#080808",  -- Deepest background
  bg1     = "#101010",  -- Main background
  bg2     = "#1c1c1c",  -- Slightly lighter background
  bg3     = "#282828",  -- Selection/highlight background
  bg4     = "#353535",  -- Lighter UI elements
  bg5     = "#404040",  -- Active statusline
  bg6     = "#333333",  -- Tabline / Inactive statusline
  bg7     = "#303030",  -- Visual highlight
  bg8     = "#3a3a2a",  -- Search highlight
  bg9     = "#3a2828",  -- Substitute highlight

  -- Foreground - Better contrast but not harsh
  fg0     = "#d4d4d4",  -- Main text
  fg1     = "#bfbfbf",  -- Dimmed text
  fg2     = "#9d9d9d",  -- Line numbers
  fg3     = "#757575",  -- Very dim text

  -- Muted but lighter colors with better contrast
  red     = "#e09090",  -- Faded but lighter red
  orange  = "#e6b380",  -- Soft but visible orange
  yellow  = "#e8d5a0",  -- Pale but contrasted yellow
  green   = "#b8d4a8",  -- Muted but lighter green
  cyan    = "#a8d0d8",  -- Soft but visible cyan
  blue    = "#9fb8d6",  -- Muted but clearer blue
  purple  = "#c8a8d4",  -- Soft but visible purple
  magenta = "#d8a8c8",  -- Muted but lighter magenta

  -- Special - Faded but more visible
  accent  = "#7a9fd8",  -- Muted but visible accent
  warning = "#e8c078",  -- Softer warning color
  error   = "#d47878",  -- Muted but visible error
  success = "#b8d4a8",  -- Soft success color
}

vim.api.nvim_set_hl(0, "Normal",      { fg = palette.fg0, bg = palette.bg0 })
vim.api.nvim_set_hl(0, "NormalFloat", { fg = palette.fg0, bg = palette.bg0 })
vim.api.nvim_set_hl(0, "FloatBorder", { fg = palette.fg3, bg = palette.bg0 })
vim.api.nvim_set_hl(0, "FloatTitle",  { fg = palette.fg1, bg = palette.bg0,
                                        bold = true })
vim.api.nvim_set_hl(0, "NormalNC",    { fg = palette.fg0, bg = palette.bg0 })
vim.api.nvim_set_hl(0, "EndOfBuffer", { fg = palette.bg3, bg = palette.bg0 })

vim.api.nvim_set_hl(0, "Cursor",       { fg = palette.bg0, bg = palette.fg0 })
vim.api.nvim_set_hl(0, "CursorLine",   { bg = palette.bg3 })
vim.api.nvim_set_hl(0, "CursorColumn", { bg = palette.bg3 })
vim.api.nvim_set_hl(0, "ColorColumn",  { bg = palette.bg2 })
vim.api.nvim_set_hl(0, "CursorLineNr", { fg = palette.accent, bold = true })
vim.api.nvim_set_hl(0, "LineNr",       { fg = palette.fg2, bg = palette.bg1 })
vim.api.nvim_set_hl(0, "SignColumn",   { fg = palette.fg2, bg = palette.bg1 })

vim.api.nvim_set_hl(0, "Visual",    { bg = palette.bg7 })
vim.api.nvim_set_hl(0, "VisualNOS", { bg = palette.bg7 })

vim.api.nvim_set_hl(0, "Search",     { fg = palette.fg0, bg = palette.bg8 })
vim.api.nvim_set_hl(0, "IncSearch",  { fg = palette.fg0, bg = palette.bg8 })
vim.api.nvim_set_hl(0, "Substitute", { fg = palette.fg0, bg = palette.bg9 })

vim.api.nvim_set_hl(0, "ModeMsg",    { fg = palette.green, bold = true })
vim.api.nvim_set_hl(0, "MoreMsg",    { fg = palette.cyan, bold = true })
vim.api.nvim_set_hl(0, "Question",   { fg = palette.yellow, bold = true })
vim.api.nvim_set_hl(0, "ErrorMsg",   { fg = palette.error, bold = true })
vim.api.nvim_set_hl(0, "WarningMsg", { fg = palette.warning, bold = true })

vim.api.nvim_set_hl(0, "Pmenu",      { fg = palette.fg1, bg = palette.bg2 })
vim.api.nvim_set_hl(0, "PmenuSel",   { fg = palette.bg0, bg = palette.accent,
                                       bold = true })
vim.api.nvim_set_hl(0, "PmenuSbar",  { bg = palette.bg4 })
vim.api.nvim_set_hl(0, "PmenuThumb", { bg = palette.fg3 })

vim.api.nvim_set_hl(0, "StatusLine",   { fg = palette.fg0, bg = palette.bg5,
                                         bold = true })
vim.api.nvim_set_hl(0, "StatusLineNC", { fg = palette.fg2, bg = palette.bg6 })

vim.api.nvim_set_hl(0, "TabLine",     { fg = palette.fg0, bg = palette.bg6 })
vim.api.nvim_set_hl(0, "TabLineSel",  { fg = palette.fg0, bg = palette.bg6,
                                        bold = true })
vim.api.nvim_set_hl(0, "TabLineFill", { fg = palette.fg3, bg = palette.bg6 })

vim.api.nvim_set_hl(0, "WinSeparator", { fg = palette.bg4 })
vim.api.nvim_set_hl(0, "VertSplit",    { fg = palette.bg4 })

vim.api.nvim_set_hl(0, "Folded",     { fg = palette.fg2, bg = palette.bg2 })
vim.api.nvim_set_hl(0, "FoldColumn", { fg = palette.fg3, bg = palette.bg1 })

vim.api.nvim_set_hl(0, "DiffAdd",    { fg = palette.green, bg = palette.bg2 })
vim.api.nvim_set_hl(0, "DiffChange", { fg = palette.yellow, bg = palette.bg2 })
vim.api.nvim_set_hl(0, "DiffDelete", { fg = palette.red, bg = palette.bg2 })
vim.api.nvim_set_hl(0, "DiffText",   { fg = palette.orange, bg = palette.bg3,
                                       bold = true })

vim.api.nvim_set_hl(0, "SpellBad",   { fg = palette.error, undercurl = true })
vim.api.nvim_set_hl(0, "SpellCap",   { fg = palette.warning, undercurl = true })
vim.api.nvim_set_hl(0, "SpellLocal", { fg = palette.cyan, undercurl = true })
vim.api.nvim_set_hl(0, "SpellRare",  { fg = palette.purple, undercurl = true })

vim.api.nvim_set_hl(0, "Comment", { fg = palette.fg3, italic = true })
vim.api.nvim_set_hl(0, "Todo",    { fg = palette.warning, bg = palette.bg2,
                                    bold = true })
vim.api.nvim_set_hl(0, "Error",   { fg = palette.error, bold = true })

vim.api.nvim_set_hl(0, "Constant",  { fg = palette.cyan })
vim.api.nvim_set_hl(0, "String",    { fg = palette.green })
vim.api.nvim_set_hl(0, "Character", { fg = palette.green })
vim.api.nvim_set_hl(0, "Number",    { fg = palette.purple })
vim.api.nvim_set_hl(0, "Boolean",   { fg = palette.purple })
vim.api.nvim_set_hl(0, "Float",     { fg = palette.purple })

vim.api.nvim_set_hl(0, "Identifier", { fg = palette.blue })
vim.api.nvim_set_hl(0, "Function",   { fg = palette.yellow })

vim.api.nvim_set_hl(0, "Statement",   { fg = palette.red })
vim.api.nvim_set_hl(0, "Conditional", { fg = palette.red })
vim.api.nvim_set_hl(0, "Repeat",      { fg = palette.red })
vim.api.nvim_set_hl(0, "Label",       { fg = palette.red })
vim.api.nvim_set_hl(0, "Operator",    { fg = palette.fg1 })
vim.api.nvim_set_hl(0, "Keyword",     { fg = palette.red })
vim.api.nvim_set_hl(0, "Exception",   { fg = palette.red })

vim.api.nvim_set_hl(0, "PreProc",   { fg = palette.orange })
vim.api.nvim_set_hl(0, "Include",   { fg = palette.orange })
vim.api.nvim_set_hl(0, "Define",    { fg = palette.orange })
vim.api.nvim_set_hl(0, "Macro",     { fg = palette.orange })
vim.api.nvim_set_hl(0, "PreCondit", { fg = palette.orange })

vim.api.nvim_set_hl(0, "Type",         { fg = palette.magenta })
vim.api.nvim_set_hl(0, "StorageClass", { fg = palette.magenta })
vim.api.nvim_set_hl(0, "Structure",    { fg = palette.magenta })
vim.api.nvim_set_hl(0, "Typedef",      { fg = palette.magenta })

vim.api.nvim_set_hl(0, "Special",        { fg = palette.cyan })
vim.api.nvim_set_hl(0, "SpecialChar",    { fg = palette.cyan })
vim.api.nvim_set_hl(0, "Tag",            { fg = palette.cyan })
vim.api.nvim_set_hl(0, "Delimiter",      { fg = palette.fg1 })
vim.api.nvim_set_hl(0, "SpecialComment", { fg = palette.fg2, italic = true })
vim.api.nvim_set_hl(0, "Debug",          { fg = palette.warning })

vim.api.nvim_set_hl(0, "Underlined", { fg = palette.blue, underline = true })
vim.api.nvim_set_hl(0, "Ignore",     { fg = palette.fg3 })
vim.api.nvim_set_hl(0, "Bold",       { bold = true })
vim.api.nvim_set_hl(0, "Italic",     { italic = true })

vim.api.nvim_set_hl(0, "@variable",           { fg = palette.fg0 })
vim.api.nvim_set_hl(0, "@variable.builtin",   { fg = palette.purple })
vim.api.nvim_set_hl(0, "@variable.parameter", { fg = palette.blue })
vim.api.nvim_set_hl(0, "@variable.member",    { fg = palette.blue })

vim.api.nvim_set_hl(0, "@constant",         { fg = palette.cyan })
vim.api.nvim_set_hl(0, "@constant.builtin", { fg = palette.purple })
vim.api.nvim_set_hl(0, "@constant.macro",   { fg = palette.orange })

vim.api.nvim_set_hl(0, "@module", { fg = palette.orange })
vim.api.nvim_set_hl(0, "@label",  { fg = palette.red })

vim.api.nvim_set_hl(0, "@string",        { fg = palette.green })
vim.api.nvim_set_hl(0, "@string.regex",  { fg = palette.cyan })
vim.api.nvim_set_hl(0, "@string.escape", { fg = palette.orange })

vim.api.nvim_set_hl(0, "@character",         { fg = palette.green })
vim.api.nvim_set_hl(0, "@character.special", { fg = palette.orange })

vim.api.nvim_set_hl(0, "@number",  { fg = palette.purple })
vim.api.nvim_set_hl(0, "@boolean", { fg = palette.purple })
vim.api.nvim_set_hl(0, "@float",   { fg = palette.purple })

vim.api.nvim_set_hl(0, "@function",         { fg = palette.yellow })
vim.api.nvim_set_hl(0, "@function.builtin", { fg = palette.cyan })
vim.api.nvim_set_hl(0, "@function.macro",   { fg = palette.orange })
vim.api.nvim_set_hl(0, "@function.method",  { fg = palette.yellow })

vim.api.nvim_set_hl(0, "@constructor", { fg = palette.magenta })
vim.api.nvim_set_hl(0, "@operator",    { fg = palette.fg1 })

vim.api.nvim_set_hl(0, "@keyword",          { fg = palette.red })
vim.api.nvim_set_hl(0, "@keyword.function", { fg = palette.red })
vim.api.nvim_set_hl(0, "@keyword.return",   { fg = palette.red })
vim.api.nvim_set_hl(0, "@keyword.operator", { fg = palette.red })

vim.api.nvim_set_hl(0, "@conditional", { fg = palette.red })
vim.api.nvim_set_hl(0, "@repeat",      { fg = palette.red })
vim.api.nvim_set_hl(0, "@exception",   { fg = palette.red })

vim.api.nvim_set_hl(0, "@type",            { fg = palette.magenta })
vim.api.nvim_set_hl(0, "@type.builtin",    { fg = palette.purple })
vim.api.nvim_set_hl(0, "@type.definition", { fg = palette.magenta })

vim.api.nvim_set_hl(0, "@attribute", { fg = palette.orange })
vim.api.nvim_set_hl(0, "@property",  { fg = palette.blue })

vim.api.nvim_set_hl(0, "@comment",         { fg = palette.fg2, italic = true })
vim.api.nvim_set_hl(0, "@comment.todo",    { fg = palette.warning,
                                             bg = palette.bg2, bold = true })
vim.api.nvim_set_hl(0, "@comment.note",    { fg = palette.cyan,
                                             bg = palette.bg2, bold = true })
vim.api.nvim_set_hl(0, "@comment.warning", { fg = palette.warning,
                                             bg = palette.bg2, bold = true })
vim.api.nvim_set_hl(0, "@comment.error",   { fg = palette.error,
                                             bg = palette.bg2, bold = true })

vim.api.nvim_set_hl(0, "@markup.heading",       { fg = palette.yellow,
                                                  bold = true })
vim.api.nvim_set_hl(0, "@markup.raw",           { fg = palette.cyan })
vim.api.nvim_set_hl(0, "@markup.link",          { fg = palette.blue })
vim.api.nvim_set_hl(0, "@markup.link.url",      { fg = palette.blue,
                                                  underline = true })
vim.api.nvim_set_hl(0, "@markup.link.label",    { fg = palette.cyan })
vim.api.nvim_set_hl(0, "@markup.list",          { fg = palette.red })
vim.api.nvim_set_hl(0, "@markup.strong",        { fg = palette.fg0,
                                                  bold = true })
vim.api.nvim_set_hl(0, "@markup.italic",        { fg = palette.fg0,
                                                  italic = true })
vim.api.nvim_set_hl(0, "@markup.strikethrough", { fg = palette.fg2,
                                                  strikethrough = true })

vim.api.nvim_set_hl(0, "DiagnosticError", { fg = palette.error })
vim.api.nvim_set_hl(0, "DiagnosticWarn",  { fg = palette.warning })
vim.api.nvim_set_hl(0, "DiagnosticInfo",  { fg = palette.cyan })
vim.api.nvim_set_hl(0, "DiagnosticHint",  { fg = palette.fg2 })

vim.api.nvim_set_hl(0, "DiagnosticUnderlineError", { undercurl = true,
                                                     sp = palette.error })
vim.api.nvim_set_hl(0, "DiagnosticUnderlineWarn",  { undercurl = true,
                                                     sp = palette.warning })
vim.api.nvim_set_hl(0, "DiagnosticUnderlineInfo",  { undercurl = true,
                                                     sp = palette.cyan })
vim.api.nvim_set_hl(0, "DiagnosticUnderlineHint",  { undercurl = true,
                                                     sp = palette.fg2 })
