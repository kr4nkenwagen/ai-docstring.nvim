local m = {}
function m.get_function_range()
	local ft = vim.bo.filetype
	if ft == "lua" then
		local h = require("ai-docstring.utils.lua-helper")
		return h.get_lua_function_range()
	elseif ft == "python" then
		local h = require("ai-docstring.utils.python-helper")
		return h.get_python_function_range()
	elseif ft == "c" or ft == "cpp" then
		local h = require("ai-docstring.utils.c-helper")
		return h.get_c_function_range()
	else
		return nil, nil
	end
end

function m.get_function_text(start_line, end_line)
	local lines = vim.api.nvim_buf_get_lines(0, start_line, end_line, false)
	return lines
end

function m.generate_doc_for_function()
	local start_line, end_line = m.get_function_range()
	if not start_line then
		vim.notify("No function found under cursor")
		return
	end
	vim.cmd(string.format("normal! %dGV%dG", start_line, end_line))
	vim.cmd("normal! ")
	if vim.bo.filetype == "python" then
		vim.cmd("normal! " .. start_line .. "G")
	else
		vim.cmd("normal! " .. start_line - 1 .. "G")
	end
	vim.cmd("normal! ")
	local func = m.get_function_text(start_line - 1, end_line)
	local ai = require("ai-docstring.utils.ai-wrapper")
	ai.query(table.concat(func, ""))
end

function m.setup(opts)
	m.config = require("ai-docstring.config")
	opts = opts or {}
	m.config = vim.tbl_deep_extend("force", m.config, opts)
	vim.keymap.set("n", m.config.key, m.generate_doc_for_function, {
		desc = "generate docstring",
		silent = true,
	})
end

return m
