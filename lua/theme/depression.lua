local api = vim.api
local set_hl = api.nvim_set_hl
local cmd = vim.cmd

cmd "colorscheme torture"

local highlights = {
	["@keyword"] = {fg = "#ff00ff", ctermfg = 201, bold = true },
	["@keyword.type"] = {fg = "#FF0000", ctermfg = 256, bold = true}
}

for name, hl in pairs(highlights) do
	set_hl(0, name, hl)
end

local links = {
	["CurSearch"]= "Search",
	["CursorLineFold"]= "CursorLine",
	["CursorLineSign"]= "CursorLine",
	["Float"]= "Number",
	["Function"]= "Identifier",
	["LineNrAbove"]= "LineNr",
	["LineNrBelow"]= "LineNr",
	["MessageWindow"]= "Pmenu",
	["Number"]= "Constant",
	["PopupNotification"]= "Todo",
	["StatusLineTerm"]= "StatusLine",
	["StatusLineTermNC"]= "StatusLineNC",
	["TabPanel"]= "Normal",
	["TabPanelFill"]= "EndOfBuffer",
	["Terminal"]= "Normal",
}

for name, link in pairs(links) do
	api.nvim_set_hl(0, name, {link = link})
end

