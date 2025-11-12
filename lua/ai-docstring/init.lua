local m = {}
function m.get_function_range()
	print(vim.bo.filetype)
	local helper = require("ai-docstring.templates." .. vim.bo.filetype)
	if helper == nil then
		return nil, nil
	end
	return helper.get_function()
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
	ai.query(table.concat(func, ""), vim.bo.filetype)
end

function m.setup(opts)
	m.config = require("ai-docstring.config")
	opts = opts or {}
	m.config = vim.tbl_deep_extend("force", m.config, opts)
	vim.keymap.set("n", m.config.key, m.generate_doc_for_function, {
		desc = "generate docstring",
		silent = true,
	})
	vim.api.nvim_create_user_command("AiGenerateDocstring", m.generate_doc_for_function, {
		bang = true,
	})
	vim.api.nvim_create_user_command("Dwadw", require("ai-docstring.templates.python").get_function, {
		bang = true,
	})
end

return m
