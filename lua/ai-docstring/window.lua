local w = {}
function w.create_output_window()
	w.config = require("ai-docstring").config
	w.buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_set_option_value("modifiable", true, { buf = w.buf })
	w.current_buf = vim.api.nvim_get_current_buf() or 0
	w.width = math.floor(vim.o.columns * 0.7)
	w.height = math.floor(vim.o.lines * 0.5)
	w.row = math.floor((vim.o.lines - w.height) / 2)
	w.col = math.floor((vim.o.columns - w.width) / 2)

	vim.api.nvim_buf_create_user_command(w.buf, "YankAndPasteBuffer", function()
		-- Get all lines in buffer
		local lines = vim.api.nvim_buf_get_lines(w.buf, 0, -1, false)
		-- Close the buffer
		vim.api.nvim_buf_delete(w.buf, { force = true })

		lines = require("ai-docstring.templates." .. vim.bo.filetype).post_process(lines)
		local win = vim.api.nvim_get_current_win()
		local row, col = unpack(vim.api.nvim_win_get_cursor(win))
		vim.api.nvim_buf_set_text(0, row, col, row, col, lines)
	end, {})

	vim.api.nvim_buf_create_user_command(w.buf, "RequestsNewGeneration", function()
		vim.fn.jobstop(w.runner)
		w.clear_buffer()
		require("ai-docstring.runner").run_async(w.cmd, w)
	end, {})
	vim.api.nvim_buf_set_keymap(w.buf, "n", "<leader>", ":YankAndPasteBuffer<CR>", { noremap = true, silent = true })
	vim.api.nvim_buf_set_keymap(w.buf, "n", "q", ":q!<CR>", { noremap = true, silent = true })
	vim.api.nvim_buf_set_keymap(w.buf, "n", "r", ":RequestsNewGeneration<CR>", { noremap = true, silent = true })

	w.win = vim.api.nvim_open_win(w.buf, true, {
		relative = "editor",
		width = w.width,
		height = w.height,
		row = w.row,
		col = w.col,
		style = "minimal",
		border = "rounded",
		title = "al-docstring | " .. w.config.ai.model,
		footer = w.config.accept_key
			.. ": Accept docstring | "
			.. w.config.renew_key
			.. ": Renew generation | "
			.. w.config.decline_key
			.. ": Discard docstring",
	})
	return w
end

function w.clear_buffer()
	vim.api.nvim_buf_set_lines(0, 0, -1, false, {})
end

function w.close_and_save(src, dest)
	local text = vim.api.nvim_buf_get_lines(src, 0, -1, false)
	vim.api.nvim_buf_delete(src, { force = true })
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	row = row - 1
	vim.api.nvim_buf_set_text(dest, row, col, row, col, text)
end
return w
