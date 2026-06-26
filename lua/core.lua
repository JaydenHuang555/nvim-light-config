
vim.loader.enable()
vim.o.termguicolors = true

local api = vim.api

local cmd = vim.cmd
local keymap = vim.keymap
local autocmd = api.nvim_create_autocmd

local buf_set_keymap = api.nvim_buf_set_keymap
local group = api.nvim_create_augroup("CORE", {clear = true})

local glob_set = keymap.set

vim.g.mapleader = ' '

vim.g.maplocalleader = ' '

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

vim.o.number = true
vim.o.relativenumber = true
vim.o.wrap = true
vim.o.expandtab = false
require 'lines'
vim.o.mouse = 'a'
vim.o.showmode = false

vim.o.breakindent = true
vim.o.smartindent = true

vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true

vim.o.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250

-- Decrease mapped sequence wait time
vim.o.timeoutlen = 300

vim.o.splitright = true
vim.o.splitbelow = true
vim.o.inccommand = 'split'

vim.o.cursorline = true
vim.o.cursorlineopt = "number"

vim.o.confirm = true

vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

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


glob_set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

glob_set("n", "<Leader>'", "", {
	desc = "Spawn term in split",
	noremap = true,
	silent = true,
	callback = function ()
		cmd "sp | term"
		api.nvim_feedkeys("i", "n", false)
	end
})

-- on ft that are quick
-- add quicker killing binds

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
		buf_set_keymap(args.buf, "n", "q", "", {
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


-- lang

autocmd("FileType", {
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
