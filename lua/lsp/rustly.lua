

local function useStandAlone()
	local cwd = vim.fn.getcwd()
	for name, type in vim.fs.dir(cwd) do
		if type == "directory" then
			if name == ".git" then
				return  false
			end
		elseif type == "file" then
			if name == "Cargo.toml" then
				return false
			end
		end
	end
	return true
end
