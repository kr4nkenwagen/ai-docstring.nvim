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

function t.get_function()
	local line_count = vim.fn.line("$")
	local cursor_line = vim.fn.line(".")
	local function_signature_pat = "%s*[%w_]+[%w_%s*&]*%s+[%w_]+%s*%([^;]*%)%s*{?"
	for lnum = 1, line_count do
		local line = vim.fn.getline(lnum)
		if line:match(function_signature_pat) then
			local func_start = lnum
			local brace_count_local = 0
			for l = func_start, line_count do
				local text = vim.fn.getline(l)
				for char in text:gmatch(".") do
					if char == "{" then
						brace_count_local = brace_count_local + 1
					elseif char == "}" then
						brace_count_local = brace_count_local - 1
					end
				end
				if brace_count_local == 0 and l >= func_start then
					local func_end = l
					if cursor_line >= func_start and cursor_line <= func_end then
						return func_start, func_end
					else
						break
					end
				end
			end
		end
	end
	return nil, nil
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
