
local api = vim.api

local keymap = vim.keymap
local autocmd = api.nvim_create_autocmd

local buf_set_keymap = api.nvim_buf_set_keymap
local group = api.nvim_create_augroup("CORE", {clear = true})

-- term

autocmd("TermEnter", {
	group = group,
	desc = "bind quick killing",
	callback = function (args)
		api.nvim_exec_autocmds("BufEnter", {
			pattern = "term"
		})
	end
})


keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

keymap.set("n", "<Leader>'", "", {
	noremap = true,
	silent = true,
	callback = function ()
		vim.cmd("sp | term")
		api.nvim_feedkeys("i", "n", false)
	end
})

-- on ft that are quick
-- add quicker killing binds

function bind_quick_death(bufnr)
	buf_set_keymap(bufnr, "n", "q", "", {
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
		"help",
		"term"
	},
	callback = function (args)
		bind_quick_death(args.buf)
	end
})


-- lang

autocmd({"BufReadPre", "BufEnter"}, {
	group = group,
	pattern = {
		"c",
		"cpp",
		"term",
		"rust",
		"rs",
		"c3",
		"zig",
	},
	callback = function (args)
		buf_set_keymap(args.buf, "n", "<Leader>;", "", {
			desc = "Apply EOS",
			noremap = true,
			callback = function ()
				local row = api.nvim_win_get_cursor(0)[1]
				local bufnr = api.nvim_get_current_buf()
				local lines = api.nvim_buf_get_lines(bufnr, row - 1, row - 1, false)
				if #lines == 0 then
					api.nvim_buf_set_lines(bufnr, row - 1, row - 1, false, {";"})
				else
					local line = lines[1] .. ";"
					api.nvim_buf_set_lines(bufnr, row - 1, row - 1, false, {line})
				end
			end
		})
	end
})

