local t = {}
t.docstring = [[
/**
 * @brief {{Brief description}} 
 *
 * {{description}}
 *
 * @param {{arg1 name}} {{arg1 description}}
 * @param {{arg2 name}} {{arg2 description}}
 * @return {{return description}}
 */]]

function t.indentation()
	return 0
end

function t.get_function()
	return require("ai-docstring.utils.functions").get_function()
end

function t.place_cursor()
	local buf = vim.api.nvim_get_current_buf()
	local row = vim.api.nvim_win_get_cursor(0)[1]
	vim.api.nvim_buf_set_lines(buf, row - 1, row - 1, true, { "" })
	vim.api.nvim_win_set_cursor(0, { row, 0 })
end

function t.post_process(docstring)
	for i = #docstring, 1, -1 do
		local line = docstring[i]
		if string.find(line, "```") or #line == 0 then
			table.remove(docstring, i)
		end
	end
	table.insert(docstring, #docstring + 1, "")
	return docstring
end
return t
