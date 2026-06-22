
local M = {}

---@param offset number
M.add = function (offset)
	local cursor = vim.api.nvim_win_get_cursor(0)
	local row = cursor[1] - 1
	local line = cursor[2]
end

return M
