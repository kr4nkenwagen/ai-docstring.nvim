local t = {}

function t.get_function()
	local node = vim.treesitter.get_node({ pos = vim.api.nvim_win_get_cursor(0) })
	while node do
		local type = node:type()
		if
			type == "function_definition"
			or type == "function_declaration"
			or type == "method_definition"
			or type:match("function")
		then
			break
		end
		node = node:parent()
	end
	if node == nil then
		return nil, nil
	end
	local start_line, _, end_row, _ = node:range()
	return start_line, end_row
end

function t.get_indentation_level()
	local start_row, _ = t.get_function()
	local line = vim.api.nvim_buf_get_lines(0, start_row, start_row + 1, false)[1]
	if not line then
		return 0
	end

	-- count leading whitespace
	local indent = line:match("^%s*")
	return #indent
end

function t.get_function_text(start_line, end_line)
	local lines = vim.api.nvim_buf_get_lines(0, start_line, end_line, false)
	return lines
end

function t.get_function_range()
	local helper = require("ai-docstring").load_language_module()
	if helper == nil then
		return nil, nil
	end
	return helper.get_function()
end

return t
