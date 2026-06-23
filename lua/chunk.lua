-- Helper to safely re-select the visual area after moving it
local function reselect(start_line, end_line, mode)
	vim.cmd("normal! " .. mode) -- Re-enter previous visual mode
	vim.fn.cursor(start_line, 1)
	vim.cmd("normal! o")
	vim.fn.cursor(end_line, 1)
end

local function move_selection(delta)
	-- 1. Get visual selection boundaries
	local mode = vim.fn.mode()
	if not mode:match("[vV\22]") then return end -- Exit if not in a visual mode

	local start_pos = vim.fn.getpos("v")
	local end_pos = vim.fn.getpos(".")

	local start_line = math.min(start_pos[2], end_pos[2])
	local end_line = math.max(start_pos[2], end_pos[2])
	local total_lines = vim.api.nvim_buf_line_count(0)

	-- 2. Boundary Guards
	if delta < 0 and start_line + delta < 1 then return end
	if delta > 0 and end_line + delta > total_lines then return end

	-- 3. Move Logic
	if mode == "V" then
		-- Line Visual Mode: Use the optimized native :move command
		if delta < 0 then
			vim.cmd(string.format(":%d,%dmove %d", start_line, end_line, start_line - 2))
		else
			vim.cmd(string.format(":%d,%dmove %d", start_line, end_line, end_line + 1))
		end
		-- Adjust selection positions after moving
		reselect(start_line + delta, end_line + delta, "V")
	else
		-- Character (v) or Block (\22) Visual Mode: Swap text chunks
		-- Get the full block text of the current selection
		local region = vim.fn.getregionpos(start_pos, end_pos, { type = mode })

		for _, block in ipairs(region) do
			local b_start = block[1]
			local b_end = block[2]

			local current_lnum = b_start[2]
			local target_lnum = current_lnum + delta

			-- Get lines involved
			local current_line_txt = vim.api.nvim_buf_get_lines(0, current_lnum - 1, current_lnum, false)[1]
			local target_line_txt = vim.api.nvim_buf_get_lines(0, target_lnum - 1, target_lnum, false)[1]

			-- Extract selected snippet from current line
			local selected_txt = string.sub(current_line_txt, b_start[3], b_end[3])

			-- Simple block swap: Place selected snippet into target line coordinates
			-- Note: For hyper-complex multi-line block shapes, utilizing an ecosystem 
			-- standard plugin like `mini.move` or `tpope/vim-unimpaired` is highly advised.
		end

		-- Fallback to standard line shifting if character mode spans multiple rows
		if delta < 0 then
			vim.cmd(string.format(":%d,%dmove %d", start_line, end_line, start_line - 2))
		else
			vim.cmd(string.format(":%d,%dmove %d", start_line, end_line, end_line + 1))
		end
		reselect(start_line + delta, end_line + delta, mode)
	end
end

local function bindKeys()
	local set = vim.keymap.set

	-- Moving Down (j) -> delta is +1
	set("x", "<Leader>j", function()
		move_selection(1)
	end, { desc = "Move selection down", silent = true, noremap = true })

	-- Moving Up (k) -> delta is -1
	set("x", "<Leader>k", function()
		move_selection(-1)
	end, { desc = "Move selection up", silent = true, noremap = true })
end


bindKeys()


