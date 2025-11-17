local t = {}

function t.get_function()
	local node = vim.treesitter.get_node({ pos = vim.api.nvim_win_get_cursor(0) })
	while node do
		local type = node:type()
		if type == "function_definition" or type == "function_declaration" or type == "method_definition" then
			break
		end
		node = node:parent()
	end
	if node == nil then
		return nil, nil
	end
	local start_line, _, end_line, _ = node:range()
	return start_line + 1, end_line + 1
end

function t.get_indentation_level()
	local start_row, _ = t.get_function()
	local indent_spaces = vim.fn.indent(start_row + 1)
	local sw = vim.api.nvim_get_option_value("shiftwidth", {})
	local indent_levels = sw > 0 and (indent_spaces / sw) or 0
	return indent_spaces, indent_levels
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
