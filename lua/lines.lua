-- LINE BARS

local group = vim.api.nvim_create_augroup("LINES HELPERS", {clear = true})

-- NUMBER

vim.api.nvim_create_autocmd("ModeChanged", {
	desc = "Switch using relative numbers",
	group = group,
	callback = function ()
		local mode = vim.fn.mode()
		if vim.wo.number then
			if mode == 'i' or mode == 't' then
				vim.wo.number = true
				vim.wo.relativenumber = false
			else
				vim.wo.number = true
				vim.wo.relativenumber = true
			end
		end
	end
})

