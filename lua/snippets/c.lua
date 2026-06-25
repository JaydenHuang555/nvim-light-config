
local M = {}

M["main"] = function()
	return {
		"int main() {",
		"	",
		"}"
	}
end

M["guard"] = function (define)
	return {
		"#ifndef " .. define,
		"#define " .. define,
		"",
		"#endif"
	}
end


return M
