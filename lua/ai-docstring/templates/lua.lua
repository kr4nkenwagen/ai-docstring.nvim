local t = {}
t.docstring = [[ 
--- {{Brief description}}
-- @tparam {{typed arg tupe}} {{typed arg name}} {{typed arg description}}
-- @param {{arg tupe}} {{arg name}} {{arg description}}
-- @treturn {{typed return type}} {{typed return description}}
-- @return {{return description}}
]]

function t.get_function()
	local start_pat = [[\v^\s*(local\s+)?function\s+\k*]]
	local start_line = vim.fn.search(start_pat, "bnW")
	if start_line == 0 then
		print("No function start found")
		return nil, nil
	end

	local line_count = vim.api.nvim_buf_line_count(0)
	local level = 1 -- start at 1 for the function itself

	for lnum = start_line + 1, line_count do
		local line = vim.api.nvim_buf_get_lines(0, lnum - 1, lnum, false)[1]

		-- Increment level for nested blocks
		if
			line:match("^%s*function[%s%(]")
			or line:match("^%s*do%s*$")
			or line:match("^%s*repeat%s*$")
			or line:match("^%s*for .* do%s*$")
			or line:match("^%s*while .* do%s*$")
			or line:match("^%s*if .* then%s*$")
		then
			level = level + 1
		end

		-- Decrement level for closing blocks
		if line:match("^%s*end%s*$") or line:match("^%s*until.*$") then
			level = level - 1
			if level == -1 then
				return start_line, lnum
			end
		end
	end

	-- fallback if function never closes
	return start_line, line_count
end

t.declaration_offset = -1

function t.post_process(docstring)
	for i = #docstring, 1, -1 do
		local line = docstring[i]
		if string.find(line, "```") or #line == 0 then
			table.remove(docstring, i)
		end
	end
	return docstring
end
return t
