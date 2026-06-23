
local buf_set_text = vim.api.nvim_buf_set_text

local function buf_anchor_right(bufnr, col_start, col_end, insert, destroyed_anchor_lnum)
	local txt = vim.api.nvim_buf_get_lines(bufnr, destroyed_anchor_lnum - 1, destroyed_anchor_lnum - 1, false)[1]

	local encoded_count = 0
	if vim.bo.fileencoding == "utf-8" then
		encoded_count = vim.fn.strcharlen(txt)
	else
		encoded_count = string.len(txt)
	end
	local built = txt
	local occupied = {}
	if encoded_count < col_start then
		occupied = {
			leading = 0,
			trailing = 0
		}
	elseif encoded_count < col_end then
		occupied = {
			leading = col_start,
			trailing = col_end - encoded_count
		}
	end

end

--[[
	ededed
]]
