
local function expandPosition(position)
return {
		bufnum = position[1],
		lnum = position[2],
		col = position[3],
		off = position[4]
	}
end

local function selectionTransform()
	local mode = vim.fn.mode()
	local anchor = vim.fn.getpos('v')
	local cursor = vim.fn.getpos('.')
	local region = vim.fn.getregionpos(anchor, cursor, {type = mode})
	local range = region[1]
	local start = expandPosition(range[1])
	local tail = expandPosition(range[2])
	if start.lnum > tail.lnum then
		return {
			head = start,
			tail = tail
		}
	else
		return {
			head = tail,
			tail = start,
		}
	end
end

-- move chunk up by 1
local function chunkUp()
	-- get visual transform
	local transform = selectionTransform()

	local top = transform.head
	local bottom = transform.tail


end

-- Example Keymap Usage
vim.keymap.set('x', '<leader>gs', function()
  chunkUp()
end, { desc = "Print current visual selection text" })
