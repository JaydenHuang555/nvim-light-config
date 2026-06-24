
local external = {
	"https://github.com/blazkowolf/gruber-darker.nvim"
}
vim.pack.add(external)

local rexim = require("gruber-darker")

rexim.setup({
	bold = true,
	invert = {
		signs = true,
		tabline = true,
		visual = true,
	},
	italic = {
		strings = false,
		comments = false,
		operators = false,
		folds = true,
	},
	undercurl = true,
	underline = true,
})

vim.cmd("colorscheme gruber-darker")
