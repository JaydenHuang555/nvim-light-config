local api = vim.api
local fn = vim.fn

local create_augroup = function (group)
	api.nvim_create_augroup(group, {clear = true})
end

local namespace = api.nvim_create_namespace("SEARCHING") 

 function buf_clear_entire_namespace(bufnr)
	api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)
end


local highlight = function ()
	local bang = function (ctx, bufnr, items)
		buf_clear_entire_namespace(bufnr) 
		local lines = api.nvim_buf_get_lines(bufnr, 0, -1, false)
		for i, line in ipairs(lines) do
			local stx, etx = string.find(line, items[i].module, 1, true)
			api.nvim_buf_set_extmark(bufnr, namespace, i - 1, stx - 1, {
				end_col = etx,
				hl_group = items[i].modules
			})
		end
		print(bufnr)
	end
	local highlights = vim.api.nvim_get_hl(0, {})
	fn.setloclist(0, {})
	---@type vim.quickfix.entry[]
	local items = {}
	for name, hl in pairs(highlights) do
		local link = hl.link
		local item = {}
		item.module = name
		item.text = link
		table.insert(items, item)
	end
	fn.setloclist(0, {}, "u", {
		items = items,
		title = "Highlights",
		context = {
			bang = bang
		}
	})
end

local themes = function ()
	local bang = function (ctx, bufnr, items)
		buf_clear_entire_namespace(bufnr)
		local row = function ()
			return api.nvim_win_get_cursor(0)[1]
		end
		local ensure_deleted_binds = function ()
			if not api.nvim_buf_is_valid(bufnr) then
				return
			end
			if vim.fn.maparg("<Cr>", "n") ~= '' then 
				api.nvim_buf_del_keymap(bufnr, "n", "<Cr>")
			end
			if vim.fn.maparg("<Leader>", "n") ~= '' then 
				api.nvim_buf_del_keymap(bufnr, "n", "<Leader>")
			end
		end
		api.nvim_buf_set_keymap(bufnr, "n", "<Cr>", "", {
			desc = "set color scheme",
			callback = function ()
				if not api.nvim_buf_is_valid(bufnr) then
					return
				end
				local item = items[row()]
				local stat = pcall(vim.cmd.colorscheme, item.module)
				if stat then 
					ctx.cached_theme_name = item.module
				end
				vim.schedule(
					function() 
						ensure_deleted_binds()
						api.nvim_buf_delete(bufnr, {}) 
					end
				)
			end,
			noremap = true,
		})
		api.nvim_buf_set_keymap(bufnr, "n", "<Leader>", "", {
			desc = "temp set color scheme",
			callback = function ()
				if not api.nvim_buf_is_valid(bufnr) then
					return
				end
				local item = items[row()]
				local stat = pcall(vim.cmd.colorscheme, item.module)
			end,
			noremap = true,
		})
		api.nvim_create_autocmd("CursorMoved", {
			buf = bufnr,
			desc = "preview theme on cursor move",
			callback = function (args)
				if args.buf ~= bufnr then
					return
				end
				if not api.nvim_buf_is_valid(bufnr) then
					return
				end
				local item = items[row()]
				vim.cmd.colorscheme(item.module) 
			end
		})
		api.nvim_create_autocmd("BufHidden", {
			buf = bufnr,
			desc = "restore preview",
			callback = function (args)
				if args.buf ~= bufnr then
					return
				end
				if not api.nvim_buf_is_valid(bufnr) then
					return
				end
				if vim.g.colors_name ~= ctx.cached_theme_name then
					vim.cmd.colorscheme(ctx.cached_theme_name) 
				end
				ensure_deleted_binds()
			end
		})
	end
	local themes = vim.fn.getcompletion('', 'color')
	---@type vim.quickfix.entry[]
	local items = {}
	for _, theme in ipairs(themes) do
		---@type vim.quickfix.entry
		local item = {
			module = theme,
			text = " ",
			lnum = 0,
		}
		table.insert(items, item)
	end
	fn.setloclist(0, {}, "u", {
		items = items,
		title = "Themes",
		context = {
			cached_theme_name = vim.g.colors_name,
			bang = bang,
		}
	})
end

local group = create_augroup("SEARCH GREPPERS")

api.nvim_create_autocmd("FileType", {
	group = group,
	pattern = "qf",
	desc = "Highlight applying listener for loclist",
	callback = function (args)
		-- TODO: add check for qf list or loclist
		local bufnr = args.buf
		local loclist = vim.fn.getloclist(0, {all = 0})
		local ctx = loclist.context
		if ctx ~= nil then
			if ctx.bang ~= nil then
				-- bangs only once
				if ctx.banged == false or ctx.banged == nil then
					local cmd = function ()
						ctx.bang(ctx, bufnr, loclist.items)
					end
					vim.schedule(cmd)
					ctx.banged = true
				end
			end
		end
	end
})


api.nvim_create_user_command("Th", function ()
	themes()
	vim.cmd("lopen")
end, {})
