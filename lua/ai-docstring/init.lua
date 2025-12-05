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
	local ai = require("ai-docstring.utils.ai-wrapper")
	local start_line, end_line = functions.get_function_range()
	if start_line == nil or end_line == nil then
		vim.notify("No function found under cursor")
		return
	end
	vim.cmd(string.format("normal! %dGV%dG", start_line, end_line))
	vim.cmd("normal! ")
	vim.cmd("normal! " .. start_line - 1 .. "G")
	vim.cmd("normal! ")
	local func = functions.get_function_text(start_line - 1, end_line)
	ai.query_docstring(table.concat(func, ""), vim.bo.filetype)
end

function m.generate_debug_lines()
	local functions = require("ai-docstring.utils.functions")
	local ai = require("ai-docstring.utils.ai-wrapper")
	local start_line, end_line = functions.get_function_range()
	if start_line == nil or end_line == nil then
		vim.notify("No function found under cursor.")
		return
	end
	local func = functions.get_function_text(start_line - 1, end_line)
	ai.query_debug_lines(table.concat(func, ""), vim.bo.filetype)
end

function m.generate_function_explaination()
	local functions = require("ai-docstring.utils.functions")
	local ai = require("ai-docstring.utils.ai-wrapper")
	local start_line, end_line = functions.get_function_range()
	if start_line == nil or end_line == nil then
		vim.notify("No function found under cursor.")
		return
	end
	local func = functions.get_function_text(start_line - 1, end_line)
	ai.query_function_explaination(table.concat(func, ""), vim.bo.filetype)
end

function m.setup(opts)
	m.config = require("ai-docstring.config")
	opts = opts or {}
	m.config = vim.tbl_deep_extend("force", m.config, opts)
	local wk = require("which-key")
	wk.add({
		{
			m.config.key,
			group = "Ollama functions generation",
			mode = { "n", "v" }, -- optional; add if needed
		},
		{ m.config.key .. "d", "<cmd>AiGenerateDocstring<CR>", desc = "Function documentation" },
		{ m.config.key .. "f", "<cmd>AiGenerateDebugLines<CR>", desc = "Function print debug lines" },
		{ m.config.key .. "g", "<cmd>AiGenerateFunctionExplaination<CR>", desc = "Function explanation" },
	})

	vim.api.nvim_create_user_command("AiGenerateDocstring", m.generate_doc_for_function, {
		bang = true,
	})
	vim.api.nvim_create_user_command("AiGenerateDebugLines", m.generate_debug_lines, {
		bang = true,
	})
	vim.api.nvim_create_user_command("AiGenerateFunctionExplaination", m.generate_function_explaination, {
		bang = true,
	})
	if m.config.ai.serve then
		vim.fn.jobstart("ollama serve &")
	end
end

return m
