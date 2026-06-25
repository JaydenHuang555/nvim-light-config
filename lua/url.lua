
local api = vim.api

local set = vim.keymap.set

local function bounds()
	local word = vim.fn.expand("<cword>")
	if word == '' then
		return nil
	end
	local cursor = api.nvim_win_get_cursor(0)
	local line = cursor[1]
	local start = vim.fn.searchpos('\\<' .. word, 'bcn', line)[2] - 1
	local tailing = vim.fn.strwidth(word)
	return {
		start,
		tailing
	}
end

set("n", "<S-x>", "", {
	callback = function ()
	end
})
