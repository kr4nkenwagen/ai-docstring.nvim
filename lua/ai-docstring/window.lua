local w = {}

w.actions = {
	DOCSTRING = 1,
	DEBUG_LINES = 2,
	FUNCTION_EXPLAINATION = 3,
}

function w.create_output_window(action)
	w.action = action
	w.config = require("ai-docstring").config
	w.buf_parent = vim.api.nvim_get_current_buf()
	w.buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_set_option_value("modifiable", true, { buf = w.buf })
	w.current_buf = vim.api.nvim_get_current_buf() or 0
	w.width = math.floor(vim.o.columns * 0.7)
	w.height = math.floor(vim.o.lines * 0.5)
	w.row = math.floor((vim.o.lines - w.height) / 2)
	w.col = math.floor((vim.o.columns - w.width) / 2)

	vim.api.nvim_buf_create_user_command(w.buf, "YankAndPasteBuffer", w.close_and_save, {})
	vim.api.nvim_buf_create_user_command(w.buf, "RequestsNewGeneration", function()
		vim.fn.jobstop(w.runner)
		w.clear_buffer()
		require("ai-docstring.runner").run_async(w.cmd, w)
	end, {})
	if w.action ~= w.actions.FUNCTION_EXPLAINATION then
		vim.api.nvim_buf_set_keymap(
			w.buf,
			"n",
			"<leader>",
			":YankAndPasteBuffer<CR>",
			{ noremap = true, silent = true }
		)
	end
	vim.api.nvim_buf_set_keymap(w.buf, "n", "q", ":q!<CR>", { noremap = true, silent = true })
	vim.api.nvim_buf_set_keymap(w.buf, "n", "r", ":RequestsNewGeneration<CR>", { noremap = true, silent = true })

	local footer = ""
	if w.action == w.actions.DOCSTRING then
		footer = w.config.accept_key
			.. ": Accept docstring | "
			.. w.config.renew_key
			.. ": Renew generation | "
			.. w.config.decline_key
			.. ": Quit window"
	elseif w.action == w.actions.DEBUG_LINES then
		footer = w.config.accept_key
			.. ": Accept print lines | "
			.. w.config.renew_key
			.. ": Renew generation | "
			.. w.config.decline_key
			.. ": Quit window"
	elseif w.action == w.actions.FUNCTION_EXPLAINATION then
		footer = w.config.renew_key .. ": Renew generation | " .. w.config.decline_key .. ": Quit window"
	end
	w.win = vim.api.nvim_open_win(w.buf, true, {
		relative = "editor",
		width = w.width,
		height = w.height,
		row = w.row,
		col = w.col,
		style = "minimal",
		border = "rounded",
		title = "ai-docstring | " .. w.config.ai.model,
		footer = footer,
	})
	return w
end

function w.set_language(lang)
	vim.api.nvim_set_option_value("filetype", lang, { buf = w.buf })
end

function w.clear_buffer()
	vim.api.nvim_buf_set_lines(0, 0, -1, false, {})
end

function w.get_buffer_text()
	return vim.api.nvim_buf_get_lines(w.buf, 0, -1, false)
end

function w.set_buffer_text(lines)
	vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
end

function w.save_docstring(text, dest)
	require("ai-docstring").load_language_module().place_cursor()
	local indentation = require("ai-docstring").load_language_module().indentation()
	text = require("ai-docstring.utils.chars").indent_text(text, indentation)
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	vim.api.nvim_buf_set_text(dest, row, col, row, col, text)
end

function w.save_debug_line(text, dest)
	local functions = require("ai-docstring.utils.functions")
	local start_line, end_line = functions.get_function()
	local indentation = functions.get_indentation_level()
	if start_line == nil or end_line == nil then
		return
	end
	text = require("ai-docstring.utils.chars").indent_text(text, indentation)
	local end_col = #vim.api.nvim_buf_get_lines(dest, end_line, end_line + 1, false)[1]
	vim.api.nvim_buf_set_text(dest, start_line, 0, end_line, end_col, text)
end

function w.close_and_save()
	if vim.fn.jobwait({ w.runner }, 0)[1] == -1 then
		return
	end
	local src = w.buf
	local dest = w.buf_parent
	local text = w.get_buffer_text()
	vim.api.nvim_buf_delete(src, { force = true })
	if w.action == w.actions.DOCSTRING then
		w.save_docstring(text, dest)
	elseif w.action == w.actions.DEBUG_LINES then
		w.save_debug_line(text, dest)
	end
end
return w
