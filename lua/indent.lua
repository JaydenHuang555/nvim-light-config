
local api = vim.api
local map = vim.keymap.set
local move = function (cords) api.nvim_win_set_cursor(0, cords) end




-- enables smart tab movement  
local enable_goofy_movement = false

if enable_goofy_movement then
	map("i", "<Right>", "", {
		callback = function()
			local cursor = api.nvim_win_get_cursor(0)
			local row = cursor[1]
			local col = cursor[2]
			local bufnr = api.nvim_get_current_buf()
			local lines = api.nvim_buf_get_lines(bufnr, row - 1, row, false)
			if #lines ~= 1 then
				return
			end
			local line = lines[1]
			if line == nil then
				return
			end
			local occupied_space = vim.fn.strwidth(line)
			if string.match(line, "%S") then
				-- handle indent shift
				local indent = vim.fn.indent(row - 1) * vim.o.shiftwidth
				if indent < col then
					move {row,col + 1}
				else
					move {row, indent}
				end
			else
				-- handle normal callback 

				if occupied_space == col then
					-- end of line
					return
				else
					move {row,col + 1}
				end
			end
		end
	})
end
