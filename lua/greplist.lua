
local api = vim.api
local ft = "greplist"

-- local greplistGroup = api.nvim_create_augroup("GREPLIST::HELPERS", {clear = true})
---@alias GrepList { maxEntries: number, shownEntries: number, entries: table, bufnr: integer, ns: integer }
---@alias Entry {line: number, col: number, source: string, label: string, display: string}
local M = {}

M.createBuffer = function ()
	local bufnr = api.nvim_create_buf(false, true)
	vim.bo[bufnr].ft = ft
	api.nvim_buf_set_keymap(bufnr, "n", "<Cr>", "", {
		callback = function ()
		end
	})
	return bufnr
end

---@return GrepList
M.create = function(ns)
	local displayBuffer = M.createBuffer()
	return {
		maxEntries = 100,
		shownEntries = 20,
		entries = {},
		bufnr = displayBuffer,
		ns = ns
	}
end


---@param grep GrepList
---@param entry Entry
M.append = function (grep, entry, highlights)
	if #grep.entries < grep.maxEntries == false then
		return false
	end

	table.insert(grep.entries, entry)


	local buffDisplayLine = #grep.entries - 1

	---@param col integer
	---@param end_col integer
	---@param group string
	local applyHighlight = function (col, end_col, group)
		vim.api.nvim_buf_set_extmark(grep.bufnr, grep.ns, buffDisplayLine, col, {
			end_col = end_col,
			hl_group = group,
		})
	end

	local src = entry.source
	local location = string.format("%d:%d", entry.line, entry.col)
	local display = string.format("|%s[%s]|[%s]:%s", src, location, entry.label, entry.display)
	vim.api.nvim_buf_set_lines(grep.bufnr, buffDisplayLine, buffDisplayLine, true, {display})
	-- |%s[%d:%d]|[%s]:%s

	-- HIGHLIGHTS 
	-- TEXT
	local fnameStart = 1
	local fnameEnd = fnameStart + string.len(src)
	applyHighlight(fnameStart, fnameEnd, highlights.fname)

	local locationStart = fnameEnd + 1
	local locationEnd = locationStart + string.len(location)
	applyHighlight(locationStart, locationEnd, highlights.location)

	local labelStart = locationEnd + 3
	local labelEnd = labelStart + string.len(entry.label)
	applyHighlight(labelStart, labelEnd, highlights.label)

	local displayStart = labelEnd + 1
	local displayEnd = displayStart + string.len(entry.display)
	vim.api.nvim_buf_set_extmark(grep.bufnr, grep.ns, buffDisplayLine, displayStart, {
		end_col = displayEnd - 1,
		hl_group = highlights.display
	})


	return true
end

---@param grep GrepList
M.clear = function (grep)
	grep.entries = {}
	vim.api.nvim_buf_clear_namespace(grep.bufnr, grep.ns, 0, -1)
	vim.api.nvim_buf_set_lines(grep.bufnr, 0, -1, false, {})
end

---@param grep GrepList
---@param enter boolean
---@param config vim.api.keyset.win_config
M.openWin = function (grep, enter, config)
	local bufnr = grep.bufnr
	vim.api.nvim_open_win(bufnr, enter, config)
end

return M
