local greplist = require("greplist")




local diagnosticHelpersGroup = vim.api.nvim_create_augroup("DIAG::HELPERS", {clear = true})
local namespaceGroup = vim.api.nvim_create_namespace("DIAG::HELPERS::NAMESPACE")

vim.lsp.diagnostic.grep = {
	list = greplist.create(namespaceGroup),
	map = {}
}

local serverityHighlightMap = {
  [vim.diagnostic.severity.ERROR] = "DiagnosticError",
  [vim.diagnostic.severity.WARN]  = "DiagnosticWarn",
  [vim.diagnostic.severity.INFO]  = "DiagnosticInfo",
  [vim.diagnostic.severity.HINT]  = "DiagnosticHint",
}

local function diagChangedCallback()
	greplist.clear(vim.lsp.diagnostic.grep.list)
	local diagnostics = vim.diagnostic.get(0)
	for _, diag in ipairs(diagnostics) do
		local name = vim.fn.bufname(diag.bufnr)
		local source = name
		local col = diag.col
		local line = diag.lnum
		local message = diag.message
		local label = string.upper(vim.diagnostic.severity[diag.severity])
		local severityHighlight = serverityHighlightMap[diag.severity]
		local highlights = {
			seperator = "@markup",
			fname = "@label",
			location = "@variable",
			label = severityHighlight,
			display = severityHighlight
		}
		local entry = {
			source = source,
			col = col,
			line = line,
			display = message,
			label = label,
		}
		greplist.append(vim.lsp.diagnostic.grep.list, entry, highlights)
	end
end

vim.api.nvim_create_autocmd("DiagnosticChanged", {
	pattern = "*",
	group = diagnosticHelpersGroup,
	callback = diagChangedCallback
})


local map = vim.keymap.set

local callback = function ()
	local list = vim.lsp.diagnostic.grep.list
	local opts = {
		split = "below"
	}
	greplist.openWin(list, true, opts)
end

map("n", "<Leader>q", callback, {
	noremap = true
})
