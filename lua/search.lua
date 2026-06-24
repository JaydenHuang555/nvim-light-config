
local api = vim.api

local M = {}

M.highlight = function ()
	local bang = function (loclist)
	end
	local highlights = vim.api.nvim_get_hl(0, {})
	vim.fn.setloclist(0, {})
	---@type vim.quickfix.entry[]
	local items = {}
	for name, hl in pairs(highlights) do
		local link = hl.link
		local item = {}
		item.module = name
		item.text = link
		table.insert(items, item)
	end
	vim.fn.setloclist(0, {}, "u", {
		items = items,
		title = "Highlights",
		context = {
			bang = bang
		}
	})
end

M.highlight()

local group = api.nvim_create_augroup("SEARCH GREPPERS", {clear = true})

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
				ctx.bang(bufnr)
			end
		end
	end
})


return M
