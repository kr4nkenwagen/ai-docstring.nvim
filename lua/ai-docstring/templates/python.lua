local t = {}
t.docstring = [[ """{{Brief description}}

    Args:
        {{arg1 name}} ({{arg1 type}}): {{arg1 description}}
        {{arg2 name}} ({{arg2 type}}): {{arg2 description}}

    Returns:
        {{return type}}: {{return description}}

    Raises:
        {{TypeError}}: {{Error description}}
    """]]

function t.indentation()
	return require("ai-docstring.utils.functions").get_indentation_level() + 2
end

function t.get_function()
	return require("ai-docstring.utils.functions").get_function_range()
end

function t.place_cursor()
	local buf = vim.api.nvim_get_current_buf()
	local row = vim.api.nvim_win_get_cursor(0)[1] + 1
	vim.api.nvim_buf_set_lines(buf, row, row, true, { "" })
	vim.api.nvim_win_set_cursor(0, { row, 0 })
end

function t.post_process(docstring)
	for i = #docstring, 1, -1 do
		if docstring[i] == "" then
			table.remove(docstring, i)
		end
	end
	local row = vim.api.nvim_win_get_cursor(0)[1]
	local line = vim.api.nvim_buf_get_lines(0, row, row + 1, false)[1] or ""
	local indent = line:match("^(%s*)") or ""
	if docstring[1] ~= '"""' then
		docstring[1] = docstring[1]:gsub('"', "")
		table.insert(docstring, 1, '"""')
	end
	if docstring[#docstring] ~= '"""' then
		docstring[#docstring] = docstring[#docstring]:gsub('"', "")
		table.insert(docstring, #docstring + 1, '"""')
	end
	for i = #docstring, 1, -1 do
		line = docstring[i]
		docstring[i] = indent .. line
		if string.find(line, "```") or #line == 0 then
			table.remove(docstring, i)
		end
	end
	return docstring
end
return t
