
local keymap = vim.keymap
local api = vim.api

local DEFAULT_HIGHLIGHTS = {
	fname = "@label",
	info = "@variable",
	label = "Error",
	message = "@attribute"
}

local buf_keymap = api.nvim_buf_set_keymap
local ns = api.nvim_create_namespace("PICKER HELPERS NS")

local entry_tracker = {}

local function occupied_cols(text)
	-- TODO: use non encoded if not using utf-8 encoding
	return vim.fn.strwidth(text)
end

local function create_buffer()
	local bufnr = api.nvim_create_buf(false, true)
	vim.bo[bufnr].ft = "diagnostics"
	buf_keymap(bufnr, "n", "<Cr>", "", {
		callback = function ()
			local entries = entry_tracker[bufnr]
			if entries == nil then
				return
			end
			local entry = entries[api.nvim_win_get_cursor(0)[1]]
			local ctx = entry.context
			local lnum = ctx.lnum
			local col = ctx.col
			local display = ctx.bufnr
			api.nvim_set_current_buf(display)
			api.nvim_win_set_cursor(0, {lnum + 1, col})
		end
	})
	buf_keymap(bufnr, "n", "q", "", {
		callback = function ()
			api.nvim_buf_delete(bufnr, {
				force = true
			})
		end
	})
	return bufnr
end

local function flush_entries(bufnr, entries)
	local lnum = 0
	api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
	local function range(txt, pattern)
		return string.find(txt, pattern, 1, true)
	end
	for _, entry in ipairs(entries) do
		local context = entry.context
		local highlights = entry.hl
		local mark = function (leading, opts)
			api.nvim_buf_set_extmark(bufnr, ns, lnum, leading, opts)
		end
		local pos = context.lnum + 1 .. ":" .. context.col
		local line = context.fname .. "|" .. pos .. "| " .. context.label .. ": " .. context.message

		api.nvim_buf_set_lines(bufnr, lnum, lnum, false, {line})

		local highlight_first = function (pattern, hl)
			local leading, trailing = range(line, pattern)
			mark(leading - 1, { hl_group = hl, end_col = trailing})
		end

		highlight_first(context.fname, highlights.fname)
		highlight_first(pos, highlights.info)
		highlight_first(context.label, highlights.label)

		local message_trailing = occupied_cols(line)
		local message_leading = occupied_cols(line) - occupied_cols(context.message)
		mark(message_leading, {hl_group = highlights.message, end_col = message_trailing})
		lnum = 1 + lnum
	end
	api.nvim_buf_set_lines(bufnr, lnum - 1, lnum - 1, false, {})
	entry_tracker[bufnr] = entries
end

local severitys= {
	[vim.diagnostic.severity.ERROR] = { hl = "Error" , label = "ERROR"},
	[vim.diagnostic.severity.WARN] = { hl = "DiagnosticWarn", label = "WARN"},
	[vim.diagnostic.severity.INFO] = { hl = "DiagnosticInfo", label = "INFO"},
	[vim.diagnostic.severity.HINT] = { hl = "DiagnosticHint", label = "HINT"},
}

local function toggle()
	local bufnr = create_buffer()

	local entries = {}

	local diagnostics = vim.diagnostic.get(0)
	for _, diagnostic in ipairs(diagnostics) do
		local context = {
			fname = vim.fn.bufname(diagnostic.bufnr),
			lnum = diagnostic.lnum,
			col = diagnostic.col,
			label = severitys[diagnostic.severity].label,
			message = diagnostic.message,
			bufnr = diagnostic.bufnr
		}
		local highlights = vim.tbl_extend("force", {}, DEFAULT_HIGHLIGHTS, {
			label = severitys[diagnostic.severity].hl
		})
		table.insert(entries, {context = context, hl = highlights})
	end

	flush_entries(bufnr, entries)
	vim.bo[bufnr].modifiable = false
	api.nvim_open_win(bufnr, true, {
		height = math.floor(vim.o.lines * 0.3),
		split = "below"
	})
end

keymap.set("n", "U", "", {
	callback = function ()
		toggle()
	end
})
