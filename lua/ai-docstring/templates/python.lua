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

function t.get_function()
	local start_pat = "\\v^\\s*def\\s+\\k+"
	local start_line = vim.fn.search(start_pat, "bnW")
	if start_line == 0 then
		print("No function start found")
		return nil, nil
	end

	local total = vim.api.nvim_buf_line_count(0)
	local start_text = vim.api.nvim_buf_get_lines(0, start_line - 1, start_line, false)[1]
	local indent = start_text:match("^(%s*)") or ""
	local end_line = total

	for i = start_line + 1, total do
		local line = vim.api.nvim_buf_get_lines(0, i - 1, i, false)[1]
		local cur_indent = line:match("^(%s*)") or ""
		local trimmed = line:match("^%s*(.-)%s*$")

		-- skip blank lines
		if trimmed ~= "" then
			-- new function or class at same/lower indentation
			if
				(#cur_indent < #indent)
				or (cur_indent == indent and line:match("^%s*def%s+"))
				or (cur_indent == indent and line:match("^%s*class%s+"))
			then
				end_line = i - 1
				break
			end
		end
	end
	-- trim trailing empty lines in the selection
	while end_line > start_line do
		local line = vim.api.nvim_buf_get_lines(0, end_line - 1, end_line, false)[1]
		if not line:match("^%s*$") then
			break
		end
		end_line = end_line - 1
	end
	return start_line, end_line
end

function t.place_cursor()
	local buf = vim.api.nvim_get_current_buf()
	local row = vim.api.nvim_win_get_cursor(0)[1]
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
