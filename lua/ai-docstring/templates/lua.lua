local t = {}
t.docstring = [[ 
--- {{Brief description}}
-- @tparam {{typed arg tupe}} {{typed arg name}} {{typed arg description}}
-- @param {{arg tupe}} {{arg name}} {{arg description}}
-- @treturn {{typed return type}} {{typed return description}}
-- @return {{return description}}
]]

function t.get_function()
	local node = vim.treesitter.get_node({ pos = vim.api.nvim_win_get_cursor(0) })
	while node do
		if node:type():match("function_declaration") then
			break
		end
		node = node:parent()
	end
	if node == nil then
		return nil, nil
	end
	local start_line, start_col, end_row, end_col = node:range()
	local line_count = end_row - start_line
	return start_line, line_count
end

function t.post_process(docstring)
	for i = #docstring, 1, -1 do
		if docstring[i] == "" then
			table.remove(docstring, i)
		end
	end
	local buf = vim.api.nvim_get_current_buf()
	local row = vim.api.nvim_win_get_cursor(0)[1]
	vim.api.nvim_buf_set_lines(buf, row, row, true, { "" })
	vim.api.nvim_win_set_cursor(0, { row, 0 })
	for i = #docstring, 1, -1 do
		local line = docstring[i]
		if string.find(line, "```") or #line == 0 then
			table.remove(docstring, i)
		end
	end
	return docstring
end
return t
