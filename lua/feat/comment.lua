local function flags(single, mhead, mtail)
	if mhead == nil or mtail == nil then
		return {
			single = single,
		}
	else
		return {
			single = single,
			mline = {
				head = mhead,
				tail = mtail
			}
		}
	end
end

local function para()
	return flags("//", "/*", "*/")
end

local filetypeFlags = {
	["c"] = para(),
	["cpp"] = para(),
	["rs"] = para(),
	["rust"] = para(),
	["py"] = flags("#"),
	["lua"] = flags("--", "--[[", "]]")
}

local group = vim.api.nvim_create_augroup("COMMENT", {clear = true})

local function getpos(e)
	local pos = vim.fn.getpos(e)
	return {
		bufnr = pos[1],
		lnum = pos[2],
		col = pos[3],
		off = pos[4]
	}
end

-- TODO: add support for multi line changes (/**/ & //)
local function commentToggleCurrentLine(bufnr, flag)
	local pos = getpos('.')
	local row = pos.lnum - 1
	local indent = vim.fn.indent('.') / vim.o.shiftwidth
	local line = vim.api.nvim_get_current_line()
	local setText = vim.api.nvim_buf_set_text
	local start_col = line:find(flag.single, 1, true)
	if start_col == nil then
		setText(bufnr, row, indent, row, indent, {string.format("%s ", flag.single)})
	else
		local end_col = start_col + #flag.single
		if line:sub(end_col + 1, end_col + 1) == " " then
			end_col = end_col + 1
		end
		setText(bufnr, row, start_col - 1, row, end_col, {})
	end
end

for ft, flag in pairs(filetypeFlags) do
	vim.api.nvim_create_autocmd("FileType", {
		desc = "Add comment detection",
		pattern = ft,
		group = group,
		callback = function ()
			local command = function ()
				local map = function (mode, lhs, callback)
					vim.api.nvim_buf_set_keymap(0, mode, lhs, "", {
						callback = callback,
						silent = false,
						noremap = true,
					})
				end
				map("n", "<C-c>", function ()
					commentToggleCurrentLine(0, flag)
				end)
			end
			vim.schedule(command)
		end
	})
end
