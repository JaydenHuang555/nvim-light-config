
local api = vim.api

local keymap = vim.keymap
local autocmd = api.nvim_create_autocmd

local group = api.nvim_create_augroup("CORE", {clear = true})

-- on ft that are quick
-- add quicker killing binds

function bind_quick_death(bufnr)
	api.nvim_buf_set_keymap(bufnr, "n", "q", "", {
		silent = true,
		desc = "quick kill",
		callback = function ()
			api.nvim_buf_delete(bufnr, {
				force = true
			})
		end
	})
end

autocmd("BufEnter", {
	group = group,
	desc = "bind quick killing",
	pattern = {
		"qf",
		"man",
		"help"
	},
	callback = function (args)
		bind_quick_death(args.buf)
	end
})

-- term

autocmd("TermEnter", {
	group = group,
	desc = "bind quick killing",
	callback = function (args)
		bind_quick_death(args.buf)
	end
})


keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

keymap.set("n", "<Leader>;", "", {
	silent = true,
	callback = function ()
		vim.cmd("sp | term")
		vim.api.nvim_feedkeys("i", "n", false)
	end
})

keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

keymap.set("n", "<Leader>'", "", {
	noremap = true,
	silent = true,
	callback = function ()
		vim.cmd("sp | term")
		vim.api.nvim_feedkeys("i", "n", false)
	end
})
