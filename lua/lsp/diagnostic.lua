
local map = vim.keymap.set

local serverityHighlightMap = {
  [vim.diagnostic.severity.ERROR] = "DiagnosticError",
  [vim.diagnostic.severity.WARN]  = "DiagnosticWarn",
  [vim.diagnostic.severity.INFO]  = "DiagnosticInfo",
  [vim.diagnostic.severity.HINT]  = "DiagnosticHint",
}

