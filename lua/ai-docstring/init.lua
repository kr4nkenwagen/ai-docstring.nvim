local m = {}

function m.load_language_module()
	local language = vim.bo.filetype
	local exp_module = {}
	local ok, module = pcall(require, "ai-docstring.templates." .. language)
	if ok then
		exp_module = module
	end
	if m.config.languages[language] ~= nil then
		exp_module = vim.tbl_deep_extend("force", module, m.config.languages[language])
	end
	return exp_module
end

function m.generate_doc_for_function()
	local functions = require("ai-docstring.utils.functions")
	local start_line, end_line = functions.get_function_range()
	if not start_line then
		vim.notify("No function found under cursor")
		return
	end
	vim.cmd(string.format("normal! %dGV%dG", start_line, end_line))
	vim.cmd("normal! ")
	vim.cmd("normal! " .. start_line - 1 .. "G")
	vim.cmd("normal! ")
	local func = functions.get_function_text(start_line - 1, end_line)
	local ai = require("ai-docstring.utils.ai-wrapper")
	ai.query_docstring(table.concat(func, ""), vim.bo.filetype)
end

function m.generate_debug_lines()
	local functions = require("lua.ai-docstring.utils.functions")
	local start_line, end_line = functions.get_function_range()
	local func = functions.get_function_text(start_line - 1, end_line)
	local ai = require("ai-docstring.utils.ai-wrapper")
	ai.query_debug_lines(table.concat(func, ""), vim.bo.filetype)
end

function m.generate_function_explaination()
	local functions = require("lua.ai-docstring.utils.functions")
	local start_line, end_line = functions.get_function_range()
	local func = functions.get_function_text(start_line - 1, end_line)
	local ai = require("ai-docstring.utils.ai-wrapper")
	ai.query_function_explaination(table.concat(func, ""), vim.bo.filetype)
end

function m.setup(opts)
	m.config = require("ai-docstring.config")
	opts = opts or {}
	m.config = vim.tbl_deep_extend("force", m.config, opts)
	vim.keymap.set("n", m.config.key, m.generate_doc_for_function, {
		desc = "Generate docstring",
		silent = true,
	})
	vim.keymap.set("n", "<leader>of", m.generate_debug_lines, {
		desc = "Generate debug lines",
		silent = true,
	})

	vim.api.nvim_create_user_command("AiGenerateDocstring", m.generate_doc_for_function, {
		bang = true,
	})
	vim.api.nvim_create_user_command("AiGenerateDebugLines", m.generate_debug_lines, {
		bang = true,
	})
end

return m
