
local api = vim.api

local group = api.nvim_create_augroup("CORE", {clear = true})

-- on ft that are quick
-- add quicker killing binds

api.nvim_create_autocmd("BufEnter", {
	group = group,
	desc = "bind quick killing",
	pattern = {
		"qf",
		"man",
		"help"
	},
	callback = function (args)
		api.nvim_buf_set_keymap(args.buf, "n", "q", "", {
			silent = true,
			desc = "quick kill",
			callback = function ()
				api.nvim_buf_delete(args.buf, {
					force = true
				})
			end
		})
	end
})
