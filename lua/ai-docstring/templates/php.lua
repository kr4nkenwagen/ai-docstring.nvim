local t = {}
t.docstring = [[
/**
 * {{Brief description of the function/method}}
 *
{{#each params}}
 * @param {{type}} {{name}} {{description}}
{{/each}}
 *
 * @return {{type}} {{description}}
 * @throws {{Exception}} {{description}}  -- optional
 */
]]

function t.get_function()
	return require("ai-docstring.utils.functions").get_function()
end

function t.indentation()
	return 0
end

function t.place_cursor()
	local buf = vim.api.nvim_get_current_buf()
	local row = vim.api.nvim_win_get_cursor(0)[1]
	vim.api.nvim_buf_set_lines(buf, row - 1, row - 1, true, { "" })
	vim.api.nvim_win_set_cursor(0, { row, 0 })
end

function t.post_process(docstring)
	for i = #docstring, 1, -1 do
		if docstring[i] == "" then
			table.remove(docstring, i)
		end
	end
	for i = #docstring, 1, -1 do
		local line = docstring[i]
		if string.find(line, "```") or #line == 0 then
			table.remove(docstring, i)
		end
	end
	return docstring
end

return t
